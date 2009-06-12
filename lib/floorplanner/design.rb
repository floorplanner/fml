module Floorplanner
  # represents surrounding: walls, areas
  class Design
    DESIGN_QUERY   = "/project/floors/floor/designs/design[id='%s']"
    LINES_QUERY    = DESIGN_QUERY+"/lines/line"
    OPENINGS_QUERY = DESIGN_QUERY+"/objects/object[type='opening']"
    AREAS_QUERY    = DESIGN_QUERY+"/areas/area"
    NAME_QUERY     = DESIGN_QUERY+"/name"
    ASSET_QUERY    = DESIGN_QUERY+"/assets/asset[@id='%s']"
    ASSETS_QUERY   = DESIGN_QUERY+"/assets/asset"
    OBJECTS_QUERY  = DESIGN_QUERY+"/objects/object"

    attr_accessor(:walls,:areas,:name)

    def initialize(fml,design_id)
      @name   = fml.find(NAME_QUERY % design_id).first.content
      @author = "John Doe" # TODO from <author> element if included in FML
      @xml    = fml
      @design_id = design_id
    end

    def build_geometries
      @areas = AreaBuilder.new do |b|
        @xml.find(AREAS_QUERY % @design_id).each do |area|
          color  = area.find('color').first.content

          vertices = Array.new
          area.find('points').first.content.split(',').each do |str_v|
            floats = str_v.strip.split(/\s/).map! {|f| f.to_f}
            vertices << b.vertex(Geom::Vertex.new(*floats[0..2]))
            vertices << b.vertex(Geom::Vertex.new(*floats[3..5]))
          end

          b.area(vertices,color)
        end
      end
      @walls  = WallBuilder.new do |b|
        @xml.find(LINES_QUERY % @design_id).each do |line|
          floats = line.find('points').first.get_floats
          
          thickness = line.find('thickness').first.content.to_f
          height = line.find('height').first.content.to_f

          sp = Geom::Vertex.new(*floats[0..2])
          ep = Geom::Vertex.new(*floats[3..5])
          sp = b.vertex(sp)
          ep = b.vertex(ep)
          b.wall(sp,ep,thickness,height)
        end
      end
      @walls.prepare
      @xml.find(OPENINGS_QUERY % @design_id).each do |opening|
        pos_floats  = opening.find('points').first.get_floats
        size_floats = opening.find('size').first.get_floats
        position = Geom::Number3D.new(*pos_floats)
        size     = Geom::Number3D.new(*size_floats)
        
        asset_id = opening.find('asset').first.attributes['refid']
        asset    = @xml.find(ASSET_QUERY % [@design_id,asset_id]).first
        type     = asset.find('url2d').first.content.match(/door/i) ? Opening3D::TYPE_DOOR : Opening3D::TYPE_WINDOW
        @walls.opening(position,size,type)
      end
      @walls.update
    end

    def assets
      return @assets if @assets
      @assets = {}
      @xml.find(ASSETS_QUERY % @design_id).each do |asset_node|
        url3d = asset_node.find('url3d')
        asset_id = asset_node.attributes['id']
        next if url3d.empty?

        asset = Floorplanner::Asset.get(asset_id, url3d.first.content)
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

        points   = object.find('points').first.content

        rotation = unless object.find('rotation').empty?
          object.find('rotation').first.content
        else
          '0 0 0'
        end
          
        asset    = assets[refid]
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
          :position => Geom::Number3D.from_str(points),
          :rotation => Geom::Number3D.from_str(rotation),
          :scale    => scale,
          :matrix   => reflection
        }
      end
      result
    end

    def to_svg
      # translate to x:0,y:0
      bbox = @walls.bounding_box
      dx = bbox[:min].distance_x(bbox[:max])
      dy = bbox[:min].distance_y(bbox[:max])
      min_x = -bbox[:min].x
      min_y = -bbox[:min].y
      # fit into document dimensions
      width , height , padding = Floorplanner.config['svg']['width'],
                                 Floorplanner.config['svg']['height'],
                                 Floorplanner.config['svg']['padding']
      ratio = ( width < height ? width : height ) * padding / ( dx > dy ? dx : dy )
      # center on stage
      mod_x = min_x + (width /ratio)/2 - dx/2
      mod_y = min_y + (height/ratio)/2 - dy/2

      template = ERB.new(
        File.read(
          File.join(Floorplanner.config['views_path'],'design.svg.erb')))
      template.result(binding)
    end

    def to_obj
      template = ERB.new(
        File.read(
          File.join(Floorplanner.config['views_path'],'design.obj.erb')))
      template.result(binding)
    end
  end
end
