module KML
  class Document < XML::Document
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
      Dir.mktmpdir do |tmpdir|
        kml_path = File.join(tmpdir,File.basename(fn,".fml"))+".kml"
        `xsltproc -o "#{kml_path}" fml2kml.xsl "#{fn}"`

        doc = KML::Document.file(kml_path)
        transforms = []
        ObjectSpace.each_object(Class) do |k|
          next if !k.ancestors.include?(XML::Node) || 
                  !k.to_s.include?('KML::Entity::') || transforms.include?(k)
          transforms << k
        end
        transforms.each do |k|
          doc.find('//'+k.to_s.split('::').last).each do |e|
            begin
              k.from_fml(e)
            rescue NoMethodError
            end
          end
        end
      end
      doc
    end
  end
end
