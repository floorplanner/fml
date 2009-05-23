module Floorplanner
  # represents surrounding: walls, areas
  class Design
    LINES_QUERY = lambda {|id| "/project/floors/floor/designs/design[id='#{id}']/lines/line"}
    AREAS_QUERY = lambda {|id| "/project/floors/floor/designs/design[id='#{id}']/areas/area"}
    def initialize(fml,id)
      @walls = WallBuilder.new do |b|
        fml.find(LINES_QUERY.call(id)).each do |line|
          floats = line.find('points').first.content.split(/\s/).map! {|f| f.to_f}
          
          thickness = line.find('thickness').first.content.to_f
          height = line.find('height').first.content.to_f

          sp = Geom::Vertex3D.new(*floats[0..2])
          ep = Geom::Vertex3D.new(*floats[3..5])
          sp = b.vertex(sp)
          ep = b.vertex(ep)
          b.wall(sp,ep,thickness,height)
        end
      end
      @areas = AreaBuilder.new do |b|
        fml.find(AREAS_QUERY.call(id)).each do |area|
          floats = area.find('points').first.content.split(/\s/).map! {|f| f.to_f}
          color  = area.find('color').first.content

          num = (floats.length/3).to_i
          vertices = Array.new(num)
          num.times do |i|
            vertices << b.vertex(Geom::Vertex3D.new(*floats[i..(i+2)]))
          end

          b.area(vertices,color)
        end
      end
    end

    def to_dae
      @walls.to_dae
    end

    def to_svg(envelope=true)
      template = ERB.new(File.read('views/design.svg.erb'))
      template.result(binding)
    end
  end
end
