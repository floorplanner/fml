module Floorplanner
  class Document
    ASSETS_QUERY  = '/project/floors/floor[1]/designs/design[1]/assets/asset'
    OBJECTS_QUERY = '/project/floors/floor[1]/designs/design[1]/objects/object'
    POINTS_QUERY  = '/project/floors/floor/designs/design/area/line/points'
    LINE_POINTS_REGEXP = /^((\s*[-+]?[0-9]*\.?[0-9]+\s+){5,8}\s*[-+]?[0-9]*\.?[0-9]+\s*?(?:,)?)*$/

    def initialize(fn)
      @xml = XML::Document.file(fn)
    end

    def self.validate(doc)
      schema = XML::RelaxNG.document(
        XML::Document.file(Floorplanner.config['fml_schema'])
      )
      doc = XML::Document.file(doc) if doc.instance_of?(String)
      doc.validate_relaxng(schema) do |message,error|
        # throw an exception in the name of love
        puts message if error
      end
    end

    def to_dae
      document = Collada::Document.new
      
      objects.each do |object|
        arch = assets[object.refid]
        # move images
        dae_asset = Collada::Asset.new(arch.dae_file)
        document.place(dae_asset,
          object.position, object.rotation, object.scale)
      end
      document
      # create new Background from self
      # call to_dae on it and place()
    end

    private
      def assets
        return @assets if @assets
        @assets = {}
        @xml.find(ASSETS_QUERY).each do |asset|
          url3d = asset.find('url3d')
          next if url3d.empty?
          arch = Keyhole::Archive.new(url3d.first.content)
          @assets.store(asset.attributes['id'], arch)
        end
        @assets
      end

      def objects
        objs = []
        @xml.find(OBJECTS_QUERY).each do |object|
          refid = object.find('asset').first.attributes['refid']
          next unless assets[refid]
          points = object.find('points').first.content
          rotation = object.find('rotation').
            first.content unless object.find('rotation').empty?
          size = object.find('size').first.content

          objs << Object.new(refid, points, rotation, size)
        end
        objs
      end

      def self.validate_line_points(doc)
        doc.find(POINTS_QUERY).each do |points_node|
          unless LINE_POINTS_REGEXP =~ points_node.children.to_s
            # throw an exception in the name of love
            puts "Elements points inside area's line failed to validate content."
          end
        end
      end
    
  end

  class Object
    attr_accessor :position
    attr_accessor :rotation
    attr_accessor :scale
    attr_accessor :refid

    def initialize(refid, points, rotation, size)
      self.refid = refid
      self.position = Geom::Number3D.from_str(points)
      self.rotation = Geom::Number3D.from_str(rotation)
      self.scale    = Geom::Number3D.from_str(size)
    end
  end
  
end
