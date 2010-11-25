module Floorplanner::XML
  class Document

    def to_dae(out_path,conf={})
      @design = Floorplanner::Design.new(self)
      @design.build_geometries
      unless conf[:xrefs]
        @design.save_textures(File.dirname(out_path))
      end
      dae = File.new(out_path,'w')
      dae.write(@design.to_dae(conf))
      dae.close
    end
  end
end

module Floorplanner
  module ColladaExport

    CACHE_PATH = File.join(Floorplanner.config['dae_cache_path'], 'textures_2d')

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
      @doc.assets.each do |asset|
        next unless asset.url3d && !asset.url3d.empty?

        # TODO: store asset bounding box
        dae = Floorplanner::DAE.get(asset)
        next unless dae
        @assets.store(asset.id, dae)
      end
      @assets
    end

    def objects
      result = []
      @doc.objects.each do |item|
          next unless assets[item.asset]
          asset = assets[item.asset]

          pos = item.position
          rot = item.rotation || Geom::Number3D.new
          scale = asset.scale_ratio(item.size)

          if item.mirrored
            m_mirror = Geom::Matrix3D.reflection(
              Geom::Plane.new(item.mirrored, Geom::Number3D.new))
          end

          m_scale     = Geom::Matrix3D.scale(scale.x, scale.y, scale.z)
          m_rotate    = Geom::Matrix3D.rotation(0, 0, 1, (Math::PI/180)*rot.z)
          m_translate = Geom::Matrix3D.translation(pos.x, pos.y, pos.z)

          m_combined  = m_rotate * m_scale
          m_combined  = m_mirror * m_combined if m_mirror
          m_combined  = m_translate * m_combined

          result << {
            :asset  => asset,
            :matrix => m_combined
          }
      end
      result
    end

    def save_textures(root_path)
      img_path = File.join(root_path, 'textures')
      FileUtils.mkdir_p img_path
      assets.each_value do |asset|
        asset.save_textures img_path
      end

      t2d_path = File.join(img_path, 'textures_2d')
      FileUtils.mkdir_p t2d_path
      @areas.each do |area|
        next unless area.data[:texture]
        texture_url = area.data[:texture]
        fn = texture_url.match(/.*\/(.*)/)[1]
        tex_path = File.join(t2d_path, fn)
        area.data[:texture] = File.join('textures', 'textures_2d', fn)
        next if File.exists?(tex_path)

        FileUtils.mkdir_p CACHE_PATH
        cached_path = File.join(CACHE_PATH, fn)
        unless File.exists?(cached_path)
          puts "Downloading texture: %s" % texture_url
          begin
            cached = File.new(cached_path, 'w')
            remote = open(Floorplanner.config['content_base_url'] + 
              URI.escape(texture_url))
            cached.write(remote.read)
            cached.close
          rescue
            $stderr.puts "Error downloading texture: %s" % fn
          end
        end
        FileUtils.cp(cached_path, tex_path)
      end
    end
  end
end
