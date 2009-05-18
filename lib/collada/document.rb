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
    VISUAL_SCENE = 'visual_scene'
    INSTANCE_VISUAL_SCENE = 'instance_visual_scene'

    attr_accessor :assets_libraries

    def initialize
      super
      self.root = XML::Node.new(COLLADA)
      self.root.namespaces.namespace = XML::Namespace.new(self.root,nil,XMLNS)
      self.root.attributes['version'] = VERSION

      create_structure

      self.assets_libraries = []
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
        materials_and_effects_added(doc.name)
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
        self << (visual_scenes = XML::Node.new(LIBRARY_VISUAL_SCENES))
        visual_scenes << (visual_scene = XML::Node.new(VISUAL_SCENE))
        visual_scene['id'] = 'MainScene'
        visual_scene['name'] = 'MainScene'

        self << (scene = XML::Node.new(SCENE))
        scene << (scene_node = XML::Node.new(INSTANCE_VISUAL_SCENE))
        scene_node['url'] = '#MainScene'
      end

      def library_visual_scenes_node
        self.find("//#{VISUAL_SCENE}").first
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
        assets_libraries.include?(namespace)
      end

      def materials_and_effects_added(namespace)
        assets_libraries << namespace
      end

      def imported(nodes)
        self.import(nodes)
      end
  end
end
