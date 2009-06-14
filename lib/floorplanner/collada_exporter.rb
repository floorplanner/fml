module Floorplanner
  module ColladaExporter
    DESIGN_QUERY   = "/project/floors/floor/designs/design[id='%s']"
    ASSET_QUERY    = DESIGN_QUERY+"/assets/asset[@id='%s']"
    ASSETS_QUERY   = DESIGN_QUERY+"/assets/asset"
    OBJECTS_QUERY  = DESIGN_QUERY+"/objects/object"

    def to_dae
      raise "No geometries to export. Call build_geometries first" unless @areas && @walls
      @assets   = assets
      @elements = objects

      # somehow...
      @walls.reverse
      @areas.each {|a| a.reverse}

      template = ERB.new(
        File.read(
          File.join(Floorplanner.config['views_path'],'design.dae.erb')))
      template.result(binding)
    end

    def assets
      return @assets if @assets
      @assets = {}
      @xml.find(ASSETS_QUERY % @design_id).each do |asset_node|
        asset_id = asset_node.attributes['id']
        url3d = asset_node.find('url3d')
        next if url3d.empty?

        asset = Floorplanner::Asset.get(asset_id,url3d.first.content)
        next unless asset
        @assets.store(asset_id, asset)
      end
      @assets
    end

    def objects
      result = []
      @xml.find(OBJECTS_QUERY % @design_id).each do |object|
        refid = object.find('asset').first.attributes['refid']
        next unless assets[refid]

        asset    = assets[refid]
        position = Geom::Number3D.from_str(object.find('points').first.content)

        # correct Flash rotation issues
        rotation = unless object.find('rotation').empty?
          object.find('rotation').first.content
        else
          '0 0 0'
        end
        rotation = Geom::Number3D.from_str(rotation)
        rotation.z += 180
        
        # find proper scale for object
        size     = object.find('size').first.content
        scale    = asset.scale_ratio(Geom::Number3D.from_str(size))
        mirrored = object.find('mirrored').first
        reflection = Geom::Matrix3D.identity
        if mirrored
          mirror   = Geom::Number3D.from_str(mirrored)
          if mirror.x != 0 || mirror.y != 0 || mirror.z != 0
            mirror.x = mirror.x > 0 ? 1 : 0
            mirror.y = mirror.y > 0 ? 1 : 0
            mirror.z = mirror.z > 0 ? 1 : 0

            origin = Geom::Number3D.new
            plane  = Geom::Plane.new(mirror,origin)
            reflection = Geom::Matrix3D.reflection(plane)
          end
        end

        result << {
          :asset => asset,
          :position => position,
          :rotation => rotation,
          :scale    => scale,
          :matrix   => reflection
        }
      end
      result
    end

    def save_textures(root_path)
      img_path = File.join(root_path,'images')
      FileUtils.mkdir_p img_path
      assets.each_value do |asset|
        a_dir = File.join(img_path,asset.name)
        asset.save_textures a_dir
      end
    end
  end
end
