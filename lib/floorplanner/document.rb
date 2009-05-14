module Floorplanner
  class Document
    ASSETS_QUERY = '/project/floors/floor/designs/design/assets/asset'
    OBJECTS_QUERY = '/project/floors/floor/designs/design/objects/object'

    attr_accessor :assets

    def initialize(fn)
      @xml = XML::Document.file(fn)
      self.assets = {}
    end
    def to_dae
      # create blank COLLADA document
      # call place() for each <fml:object>
      load_assets
      objects.each do |object|
        # get approporate asset
        # Collada::Document.place
      end
      
      # create new Background from self
      # call to_dae on it and place()
    end

    private
    def load_assets
      @xml.find(ASSETS_QUERY).each do |asset|
        url3d = asset.find('url3d')
        next if url3d.empty?
        arch = Keyhole::Archive.new(url3d.first.content)
#        arch.dae_file
        self.assets.store(asset.attributes['id'], arch)
      end
    end

    def objects
      @xml.find(OBJECTS_QUERY).each do |object|
        
      end
    end

  end

  class Object
    attr_accessor :points
    attr_accessor :rotation
  end
  
end
