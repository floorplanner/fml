require 'tmpdir'
require 'zip/zip'
require 'rubygems'
require 'xml'

module KML
  class Archive < Zip::ZipFile
    def initialize(fn,&block)
      super(fn,Zip::ZipFile::CREATE)
      begin
        mkdir("images")
        mkdir("models")
      rescue Errno::EEXIST
      end
      @documents = []
      if block
        block.call(self)
        close
      end
    end

    def add_image(fn)
      path = File.join("images",File.basename(fn))
      begin
        add(path,fn)
      rescue Zip::ZipEntryExistsError
        puts "File #{path} exists, skipping"
      end
    end

    def add_model(fn)
      path = File.join("models",File.basename(fn))
      begin
        add(path,fn)
      rescue Zip::ZipEntryExistsError
        puts "File #{path} exists, skipping"
      end
    end

    def add_document(doc)
      @documents << doc
    end

    def close
      Dir.mktmpdir do |tmpdir|
        @documents.each_with_index do |doc,i|
          fn = File.join(tmpdir,"doc_#{i}.kml")
          doc.save(fn)
          begin
            add(File.basename(fn),fn)
          rescue Zip::ZipEntryExistsError
            puts "File doc_#{i}.kml exists, skipping"
          end
        end
        super
      end
    end
  end

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
  end

  module Entity
    class Placemark < XML::Node
      def initialize(name,description=nil)
        super('Placemark')
        self << XML::Node.new('name',name)
        self << XML::Node.new('description',description) if description
      end
    end

    class Model < XML::Node
      def initialize(id)
        super('Model')
        self.attributes['id'] = id
      end
    end

    class Link < XML::Node
      def initialize(href)
        super('Link')
        self << XMl::Node.new('href',href.to_s)
      end
    end

    class Location < XML::Node
      def initialize(lon,lat,alt)
        super('Location')
        self << XML::Node.new('longitude',lon.to_s)
        self << XML::Node.new('latitude', lat.to_s)
        self << XML::Node.new('altitude', alt.to_s)
      end
    end

    class Orientation < XML::Node
      def initialize(heading=0.0,tilt=0.0,roll=0.0)
        super('Orientation')
        self << XML::Node.new('heading',heading.to_s)
        self << XML::Node.new('tilt',tilt.to_s)
        self << XML::Node.new('roll',roll.to_s)
      end
    end

    class Scale < XML::Node
      def initialize(x,y,z)
        super('Scale')
        self << XML::Node.new('x',x.to_s)
        self << XML::Node.new('y',y.to_s)
        self << XML::Node.new('z',z.to_s)
      end
    end
  end
end
