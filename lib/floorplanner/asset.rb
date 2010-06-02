module Floorplanner
  class DAE
    LIBRARY_GEOMETRIES   = '/COLLADA/library_geometries/geometry'
    LIBRARY_EFFECTS      = '/COLLADA/library_effects/effect'
    LIBRARY_MATERIALS    = '/COLLADA/library_materials/material'
    LIBRARY_NODES        = '/COLLADA/library_nodes/node'
    LIBRARY_IMAGES       = '/COLLADA/library_images/image'
    VISUAL_SCENE_QUERY   = '/COLLADA/library_visual_scenes/visual_scene/node'

    NO_NS_NAME = %w{ param }

    CACHE_PATH = File.join(Floorplanner.config['dae_cache_path'], 'kmz')

    attr_reader :id, :name, :title, :dae_path

    def self.get(asset_id,asset_title,asset_url3d)
      FileUtils.mkdir_p(CACHE_PATH)
      asset_url = Floorplanner.config['content_base_url'] + URI.escape(asset_url3d)

      cached_path = File.join(CACHE_PATH,asset_id)
      if File.exists?(cached_path)
        $stderr.puts("Cached asset: %s" % asset_id)
        @kmz = Keyhole::Archive.new(cached_path)
        DAE.new(asset_id,asset_title,@kmz)
      else
        $stderr.puts("Downloading asset: %s" % asset_url)
        cached = File.new(cached_path,'w')
        remote = open(asset_url)
        cached.write(remote.read)
        cached.close

        @kmz = Keyhole::Archive.new(cached_path)
        asset = DAE.new(asset_id,asset_title,@kmz)
        asset.adjust_paths!
        asset
      end
    rescue
      $stderr.puts "Failed to get asset: %s, %s" % [asset_id, asset_url]
      raise
    end

    def initialize(id,title,kmz)
      @dae_path = kmz.dae_path(id)
      @kmz   = kmz
      @id    = id
      @title = title
      @xml   = XML::Document.string(File.read(@dae_path).gsub(/xmlns=".+"/, ''))
      @name  = File.basename(@dae_path.gsub(/\.|dae/,''))
      @images_dict = {}
    end

    def measurement_unit
    end

    def library_materials
      return @materials if @materials
      materials = @xml.find(LIBRARY_MATERIALS)
      materials.each {|mat| namespace!(mat)}
      @materials = materials
    end

    def library_effects
      return @effects if @effects
      effects = @xml.find(LIBRARY_EFFECTS)
      effects.each {|eff| namespace!(eff)}
      @effects = effects
    end

    def library_geometries
      return @geometries if @geometries
      geometries = @xml.find(LIBRARY_GEOMETRIES)
      geometries.each{|geo| namespace!(geo)}
      @geometries = geometries
    end

    def library_nodes
      return @nodes if @nodes
      nodes = @xml.find(LIBRARY_NODES)
      nodes.each{|nod| namespace!(nod)}
      @nodes = nodes
    end

    def library_images
      return @images if @images
      images = @xml.find(LIBRARY_IMAGES)
      images.each{|img| namespace!(img) && update_path!(img)}
      @images = images
    end

    def visual_scene_node
      return @scene_node if @scene_node
      @scene_node = namespace!(@xml.find(VISUAL_SCENE_QUERY).first)
    end

    def bounding_box
      mesh = Collada::Geometry.doc @xml
      mesh.bounding_box
    end

    def bounding_box_size
      box = bounding_box
      Geom::Number3D.new(
        box[:max].distance_x(box[:min]),
        box[:max].distance_y(box[:min]),
        box[:max].distance_z(box[:min])
      )
    end

    def scale_ratio(target_size)
      bbox_size = bounding_box_size
      result = Geom::Number3D.new

      result.x = target_size.x / bbox_size.x
      result.y = target_size.y / bbox_size.y
      result.z = 0.01 # (result.x + result.y) / 2.0 # TODO: correct Z size in FML

      result
    end

    def save_textures(root_path)
      images = @xml.find(LIBRARY_IMAGES)
      FileUtils.mkdir_p(root_path) unless images.length.zero?

      images.each do |image|
        relative_to_dae = image.find('init_from').first.content
        img_path = @kmz.image_path(@id,relative_to_dae)
        target_path = File.join(root_path,@id)
        FileUtils.mkdir_p target_path

        target = open(File.join(target_path,File.basename(img_path)),'w')
        target.write(File.read(img_path))
        target.close
        @images_dict[relative_to_dae] = relative_to_dae[3..-1]
      end
    end

    def adjust_paths!
      images = @xml.find(LIBRARY_IMAGES)

      images.each do |image|
        init_from = image.find('init_from').first
        img_path = @kmz.image_path(@id,init_from.content,true)
        init_from.content = img_path
      end
      open(@dae_path, 'w') do |f|
        f.write @xml.to_s
      end
    end

    private

    def namespace!(node)
      node['id'] = "#{@name}_#{node['id']}" if node['id']
      node['sid'] = "#{@name}_#{node['sid']}" if node['sid'] && node['sid'] != 'COMMON'
      node['name'] = "#{@name}_#{node['name']}" if node['name'] && !NO_NS_NAME.include?(node.name)
      node['symbol'] = "#{@name}_#{node['symbol']}" if node['symbol']
      node['material'] = "#{@name}_#{node['material']}" if node['material']


      node['url'] = "##{@name}_#{node['url'].gsub('#','')}" if node['url']
      node['target'] = "##{@name}_#{node['target'].gsub('#','')}" if node['target']
      node['source'] = "##{@name}_#{node['source'].gsub('#','')}" if node['source']
      node['texture'] = "#{@name}_#{node['texture'].gsub('#','')}" if node['texture']

      if node.name == 'surface'
        n = node.find('init_from').first
        n.content = "#{@name}_#{n.content}"
      end

      if node.name == 'sampler2D'
        n = node.find('source').first
        n.content = "#{@name}_#{n.content}"
      end

      node.children.each do |children|
        namespace!(children)
      end
      node
    end

    # updates image path to export output folder
    def update_path!(node)
      init_from_node = node.find('init_from').first
      relative = init_from_node.content
      init_from_node.content = @images_dict[relative]
    end
  end
end
