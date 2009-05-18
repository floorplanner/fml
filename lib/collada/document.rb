module Collada
  class Document < XML::Document
    XMLNS = "http://www.collada.org/2005/11/COLLADASchema"
    VERSION = "1.4.1"

    ASSET = 'asset'
    LIBRARY_MATERIALS = 'library_materials'
    LIBRARY_EFFECTS = 'library_effects'
    LIBRARY_GEOMETRIES = 'library_geometries'
    LIBRARY_VISUAL_SCENES = 'library_visual_scenes'
    SCENE = 'scene'

    def initialize
      super
      self.root = XML::Node.new('COLLADA')
      self.root.namespaces.namespace = XML::Namespace.new(self.root,nil,XMLNS)
      self.root.attributes['version'] = VERSION

      create_structure
    end

    def << (node)
      root << node
    end

    def place(doc,position,rotation,scale)
      library_visual_scenes_node << doc.library_visual_scenes
      # merge in doc, and instantiate at visual scene
      # with given coordinates
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
        self.root.find(LIBRARY_VISUAL_SCENES).first
      end

      def library_geometries_node
      end

      def library_effects_node
      end

      def library_materials_node
      end
  end
end
