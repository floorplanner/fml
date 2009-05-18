require 'cgi'

module Collada
  class Document < XML::Document
    XMLNS = "http://www.collada.org/2005/11/COLLADASchema"
    VERSION = "1.4.1"

    COLLADA = 'COLLADA'
    ASSET = 'asset'
    LIBRARY_MATERIALS = 'library_materials'
    LIBRARY_EFFECTS = 'library_effects'
    LIBRARY_GEOMETRIES = 'library_geometries'
    LIBRARY_VISUAL_SCENES = 'library_visual_scenes'
    SCENE = 'scene'

    def initialize
      super
      self.root = XML::Node.new(COLLADA)
      self.root.namespaces.namespace = XML::Namespace.new(self.root,nil,XMLNS)
      self.root.attributes['version'] = VERSION

      create_structure
    end

    def << (node)
      root << node
    end

    def place(doc,position,rotation,scale)
      unless materials_and_effects_included?(doc.name)
        doc.library_materials.each do |material|
          library_materials_node << imported(material)
        end
        doc.library_effects.each do |effect|
          library_effects_node << imported(effect)
        end
      end

      doc.library_geometries.each do |geometry|
        library_geometries_node << imported(geometry)
      end
      library_visual_scenes_node << imported(doc.library_visual_scenes)
    end

    private
      def create_structure
        self << XML::Node.new(ASSET)

        self << XML::Node.new(LIBRARY_MATERIALS)
        self << XML::Node.new(LIBRARY_EFFECTS)
        self << XML::Node.new(LIBRARY_GEOMETRIES)
        self << XML::Node.new(LIBRARY_VISUAL_SCENES)

        self << XML::Node.new(SCENE)
      end

      def library_visual_scenes_node
        find_node(LIBRARY_VISUAL_SCENES)
      end

      def library_geometries_node
        find_node(LIBRARY_GEOMETRIES)
      end

      def library_effects_node
        find_node(LIBRARY_EFFECTS)
      end

      def library_materials_node
        find_node(LIBRARY_MATERIALS)
      end

      def find_node(node_name)
        self.root.find(node_name).first
      end

      def materials_and_effects_included?(namespace)
        false
      end

      def imported(nodes)
        self.import(nodes)
      end
  end
end
