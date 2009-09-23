module Floorplanner
  class Design
    DESIGN_QUERY   = "/project/floors/floor/designs/design[id='%s']"
    DESIGN_N_QUERY = "/project/floors/floor/designs/design[name='%s']"
    ASSET_QUERY    = DESIGN_QUERY+"/assets/asset[@id='%s']"
    ASSET_URL2D    = ASSET_QUERY+"/url2d"
    LINES_QUERY    = DESIGN_QUERY+"/lines/line"
    OPENINGS_QUERY = DESIGN_QUERY+"/objects/object[type='opening']"
    AREAS_QUERY    = DESIGN_QUERY+"/areas/area"
    NAME_QUERY     = DESIGN_QUERY+"/name"

    include ColladaExport
    include ObjExport
    include RibExport
    include SvgExport

    ##
    # Constructs new floorplan design from FML
    ##
    def initialize(fml,design_id)
      begin
        @xml = fml
        unless fml.find(DESIGN_QUERY % design_id).length.zero?
          @design_id = design_id
        else
          @design_id = fml.find(DESIGN_N_QUERY % design_id).first.find("id").first.content
        end
        @name   = @xml.find(NAME_QUERY % @design_id).first.content
        @author = "John Doe" # TODO from <author> element if included in FML
      rescue NoMethodError
        $stderr.puts "Can't find Design with ID or name: %s" % design_id
      end
    end

    ##
    # Builds geometries of walls and areas.
    ##
    def build_geometries
      @areas = AreaBuilder.new do |b|
        @xml.find(AREAS_QUERY % @design_id).each do |area|
          name  = area.find('name').first.content
          color = area.find('color').first.content
          type  = area.find('type').first.content

          asset_id = area.find('asset').first.attributes['refid']
          texture_url = @xml.find(ASSET_URL2D % [@design_id,asset_id]).first.content

          vertices = Array.new
          area.find('points').first.content.split(',').each do |str_v|
            floats = str_v.strip.split(/\s/).map! {|f| f.to_f}

            # TODO: fix y coords in Flash app
            floats[1] *= -1.0; floats[4] *= -1.0

            vertices << b.vertex(Geom::Vertex.new(*floats[0..2]))
            vertices << b.vertex(Geom::Vertex.new(*floats[3..5]))
          end

          b.area(vertices,
            :color => color,
            :name => name,
            :texture => texture_url,
            :type => type)

        end
      end
      min_height = 10
      @walls = WallBuilder.new do |b|
        @xml.find(LINES_QUERY % @design_id).each do |line|
          floats = line.find('points').first.get_floats

          thickness = line.find('thickness').first.content.to_f
          height = line.find('height').first.content.to_f

          # TODO: fix this in Flash app
          floats[1] *= -1.0; floats[4] *= -1.0

          sp = Geom::Vertex.new(*floats[0..2])
          ep = Geom::Vertex.new(*floats[3..5])
          sp = b.vertex(sp)
          ep = b.vertex(ep)
          b.wall(sp,ep,thickness,height)
          min_height = height if height < min_height
        end
      end
      @areas.update min_height

      @walls.prepare
      @xml.find(OPENINGS_QUERY % @design_id).each do |opening|
        pos_floats  = opening.find('points').first.get_floats

        # TODO: fix y coord in Flash app
        pos_floats[1] *= -1

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
  end
end
