module Collada
  class Document < XML::Document
    XMLNS = "http://www.collada.org/2005/11/COLLADASchema"
    VERSION = "1.4.1"
    VISUAL_SCENES = 'library_visual_scenes'
    
    def initialize
      super
      self.root = XML::Node.new('COLLADA')
      self.root.namespaces.namespace = XML::Namespace.new(self.root,nil,XMLNS)
      self.root.attributes['version'] = VERSION
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
      def library_visual_scenes_node
        visual_scenes = self.root.find(VISUAL_SCENES)
        if (visual_scenes.empty?)
          self << XML::Node.new('library_visual_scenes')
          visual_scenes = self.root.find(VISUAL_SCENES)
        end
        visual_scenes.first
      end

      def library_geometries_node
      end

      def library_effects_node
      end

      def library_materials_node
      end
  end
end
