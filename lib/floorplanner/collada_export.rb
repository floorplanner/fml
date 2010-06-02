module Floorplanner
  class DesignDocument

    def to_dae(out_path,conf={})
      @design = Design.new(@xml)
      @design.build_geometries
      unless conf[:xrefs]
        @design.save_textures(File.dirname(out_path))
      end
      dae = File.new(out_path,'w')
      dae.write(@design.to_dae(conf))
      dae.close
    end

  end

  module ColladaExport
    DESIGN_QUERY   = "/design"
    ASSET_QUERY    = DESIGN_QUERY+"/assets/asset[@id='%s']"
    ASSETS_QUERY   = DESIGN_QUERY+"/assets/asset"
    OBJECTS_QUERY  = DESIGN_QUERY+"/objects/object"

    def to_dae(conf)
      raise "No geometries to export" unless @areas && @walls
      @assets   = assets
      @elements = objects

      # somehow...
      @walls.reverse
      @areas.each {|a| a.reverse}
      @conf = conf

      template = ERB.new(
        File.read(
          File.join(File.dirname(__FILE__), '..', '..', 'views', 'design.dae.erb')))
      template.result(binding)
    end

    def assets
      return @assets if @assets
      @assets = {}
      @xml.find(ASSETS_QUERY).each do |asset_node|
        asset_id = asset_node.attributes['id']
        name  = asset_node.find('name').first
        name  = name.content if name
        url3d = asset_node.find('url3d').first
        next unless url3d
        url3d = url3d.content
        next if url3d.empty?

        # TODO: store asset bounding box
        asset = Floorplanner::DAE.get(asset_id,name,url3d)
        next unless asset
        @assets.store(asset_id, asset)
      end
      @assets
    end

    def objects
      result = []
      @xml.find(OBJECTS_QUERY).each do |object|
        begin
          refid = object.find('asset').first.attributes['refid']
          next unless assets[refid]

          asset = assets[refid]
          pos = Geom::Number3D.from_str(object.find('points').first.content)
          pos.y *= -1.0 # correct Flash axis issues

          # correct Flash rotation issues
          rotation = unless object.find('rotation').empty?
            object.find('rotation').first.content
          else
            '0 0 0'
          end
          rot = Geom::Number3D.from_str(rotation)
          rot.z += 360 if rot.z < 0
          rot.z += 180

          # find proper scale for object
          size     = object.find('size').first.content
          scale    = asset.scale_ratio(Geom::Number3D.from_str(size))
          
          mirrored = object.find('mirrored').first
          reflection = Geom::Matrix3D.reflection(Geom::Plane.new(Geom::Number3D.new(0.0,1.0,0.0), Geom::Number3D.new))
          if mirrored
            mirror = Geom::Number3D.from_str(mirrored.content)
            if mirror.x != 0 || mirror.y != 0 || mirror.z != 0
              mirror.x = mirror.x > 0 ? 1 : 0
              mirror.y = mirror.y > 0 ? 1 : 0
              mirror.z = mirror.z > 0 ? 1 : 0

              origin = Geom::Number3D.new
              plane  = Geom::Plane.new(mirror,origin)
              m_reflection = Geom::Matrix3D.reflection(plane) * reflection
            end
          end

          m_scale     = Geom::Matrix3D.scale(scale.x, scale.y, scale.z)
          m_translate = Geom::Matrix3D.translation(pos.x, pos.y, pos.z)
          m_rotate    = Geom::Matrix3D.rotation(0, 0, 1, (Math::PI/180)*rot.z)

          m_combined  = m_scale * m_rotate
          m_combined  = m_reflection * m_combined if m_reflection
          m_combined  = m_translate * m_combined

          result << {
            :asset  => asset,
            :matrix => m_combined
          }
        rescue
          $stderr.puts "Error of object asset##{refid} - #{$!}"
        end
      end
      result
    end

    def save_textures(root_path)
      img_path = File.join(root_path,'textures')
      FileUtils.mkdir_p img_path
      assets.each_value do |asset|
        asset.save_textures img_path
      end
    end
  end
end
