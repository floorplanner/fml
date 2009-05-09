module KML
  class Document < XML::Document
    extend Transformable
    XMLNS = "http://www.opengis.net/kml/2.2"
    def initialize
      super
      self.root = XML::Node.new('kml')
      self.root.namespaces.namespace = XML::Namespace.new(self.root,nil,XMLNS)
    end

    def <<(node)
      root << node
    end

    def self.from_fml(fn)
      doc = nil
      stylesheet_doc = XML::Document.file('fml2kml.xsl')
      stylesheet = XSLT::Stylesheet.new(stylesheet_doc)
      fml_doc = XML::Document.file(fn)
      doc = stylesheet.apply(fml_doc)

      self.transform('KML::Element::') do |t|
        doc.find('//'+t.to_s.split('::').last).each do |e|
          begin
            t.from_fml(e)
          rescue NoMethodError
          end
        end
      end
      doc
    end
  end
end
