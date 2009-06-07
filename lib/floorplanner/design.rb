module Floorplanner
  # represents surrounding: walls, areas
  class Design
    DESIGN_QUERY   = lambda {|id| "/project/floors/floor/designs/design[id='#{id}']"}
    LINES_QUERY    = lambda {|id| DESIGN_QUERY.call(id)+"/lines/line"}
    OPENINGS_QUERY = lambda {|id| DESIGN_QUERY.call(id)+"/objects/object[type='opening']"}
    AREAS_QUERY    = lambda {|id| DESIGN_QUERY.call(id)+"/areas/area"}
    NAME_QUERY     = lambda {|id| DESIGN_QUERY.call(id)+"/name"}
    ASSETS_QUERY   = lambda {|id,a_id| DESIGN_QUERY.call(id)+"/assets/asset[@id='#{a_id}']"}

    def initialize(fml,id)
      @name   = fml.find(NAME_QUERY.call(id)).first.content
      @author = "John Doe" # TODO from <author> element if included in FML
      @areas = AreaBuilder.new do |b|
        fml.find(AREAS_QUERY.call(id)).each do |area|
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
        fml.find(LINES_QUERY.call(id)).each do |line|
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
      fml.find(OPENINGS_QUERY.call(id)).each do |opening|
        pos_floats  = opening.find('points').first.get_floats
        size_floats = opening.find('size').first.get_floats
        position = Geom::Number3D.new(*pos_floats)
        size     = Geom::Number3D.new(*size_floats)
        
        asset_id = opening.find('asset').first.attributes['refid']
        asset    = fml.find(ASSETS_QUERY.call(id,asset_id)).first
        type     = asset.find('url2d').first.content.match(/door/i) ? Opening3D::TYPE_DOOR : Opening3D::TYPE_WINDOW
        @walls.opening(position,size,type)
      end
      @walls.update
    end

    def to_dae
      @walls.reverse
      @areas.each {|a| a.reverse}
      template = ERB.new(
        File.read(
          File.join(Floorplanner.config['views_path'],'design.dae.erb')))
      template.result(binding)
    end

    def to_svg
      # translate to x:0,y:0
      min_x = min_y =  100000
      max_x = max_y = -100000
      @walls.collect{|w| w.outline.vertices}.flatten.each do |v|
        min_x = v.x if v.x < min_x
        min_y = v.y if v.y < min_y
        max_x = v.x if v.x > max_x
        max_y = v.y if v.y > max_y
      end
      dx = min_x < 0 ? -min_x + max_x : max_x - min_x
      dy = min_y < 0 ? -min_y + max_y : max_y - min_y
      min_x = -min_x
      min_y = -min_y
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

    def display_gl
      d = Geom::DisplayGL.new(@walls,"Floorplanner Design")
      d.display
    end
  end
end
