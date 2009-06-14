module Floorplanner
  # represents surrounding: walls, areas
  class Design
    DESIGN_QUERY   = "/project/floors/floor/designs/design[id='%s']"
    LINES_QUERY    = DESIGN_QUERY+"/lines/line"
    OPENINGS_QUERY = DESIGN_QUERY+"/objects/object[type='opening']"
    AREAS_QUERY    = DESIGN_QUERY+"/areas/area"
    NAME_QUERY     = DESIGN_QUERY+"/name"

    include ColladaExport
    include SvgExport

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
  end
end
