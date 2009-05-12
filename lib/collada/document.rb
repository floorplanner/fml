module Collada
  class Document < XML::Document
    XMLNS = "http://www.collada.org/2005/11/COLLADASchema"
    VERSION = "1.4.1"
    def initialize
      self.root = XML::Node.new('kml')
      self.root.namespaces.namespace = XML::Namespace.new(self.root,nil,XMLNS)
      self.root.attributes['version'] = VERSION
    end

    def << (node)
      root << node
    end

    def place(doc,position,rotation,scale)
      # merge in doc, and instantiate at visual scene
      # with given coordinates
    end
  end
end
