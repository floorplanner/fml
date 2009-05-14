module Floorplanner
  class Document
    ASSETS_QUERY = '/project/floors/floor/designs/design/assets/asset'
    OBJECTS_QUERY = '/project/floors/floor/designs/design/objects/object'

    def initialize(fn)
      @xml = XML::Document.file(fn)
    end

    def to_dae
      document = Collada::Document.new
      
      objects.each do |object|
        next unless (arch = assets[object.refid])
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
        objects = []
        @xml.find(OBJECTS_QUERY).each do |object|
          refid = object.find('asset').first.attributes['refid']
          points = object.find('points').first.content
          rotation = object.find('rotation').
            first.content unless object.find('rotation').empty?
          size = object.find('size').first.content

          objects << Object.new(refid, points, rotation, size)
        end
        objects
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
