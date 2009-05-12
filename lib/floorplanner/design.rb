module Floorplanner
  # represents surrounding: walls, areas
  class Design
    LINES_QUERY = '/project/floors/floor/designs/design/lines/line'
    def initialize(fml)
      @connections = Hash.new
      @vertices = Array.new
      @walls = Array.new

      fml.find(LINES_QUERY).each do |line|
        floats = line.find('points').first.content.split(/\s/).map! {|f| f.to_f}
        
        thickness = line.find('thickness').first.content.to_f
        height = line.find('height').first.content.to_f

        sp = Geom::Vertex3D.new(*floats[0..2])
        ep = Geom::Vertex3D.new(*floats[3..5])
        sp = add_vertex(sp)
        ep = add_vertex(ep)
        add_wall(sp,ep,thickness,height)
      end
    end

    def update
      @walls.each do |wall|
        wall.update_before
      end
      @vertices.each do |v|
        connections = @connections[v]
        next if connections.length.zero?

        connections.each do |c|
          x = c[:point].x - v.x
          y = c[:point].y - v.y
          c[:angle] = Math.atan2(y,x);
        end
        connections.sort! {|a,b| a[:angle] <=> b[:angle]}
        connections.each_index do |i|
          j = (i+1) % connections.length

          w0 = find_wall(v,connections[i][:point])
          w1 = find_wall(v,connections[j][:point])

          flipped0 = (w0.baseline.end_point === v)
          flipped1 = (w1.baseline.end_point === v)

          e0 = flipped0 ? w0.outer : w0.inner;
          e1 = flipped1 ? w1.inner : w1.outer;

          isect = Geom::Intersection.lines(e0.start_point.position,e0.end_point.position,e1.start_point.position,e1.end_point.position,true)
        end
      end
    end

    def to_dae
    end

    private
      def add_vertex(vertex)
        if i = @vertices.index(vertex)
          @vertices[i]
        else
          @vertices << vertex
          vertex
        end
      end

      def add_wall(sp,ep,thickness,height)
        @connections[sp] = Array.new unless @connections.include?(sp)
        @connections[ep] = Array.new unless @connections.include?(ep)
        @connections[sp] << {:point => ep, :angle => 0.0}
        @connections[ep] << {:point => sp, :angle => 0.0}
        @walls << Geom::Wall.new(Geom::Edge.new(sp,ep), thickness, height, "wall_#{@walls.length}")
      end

      def find_wall(sp,ep)
        @walls.each do |wall|
          if wall.baseline.start_point == sp && wall.baseline.end_point == ep
            return wall
          elsif wall.baseline.end_point == sp && wall.baseline.start_point = ep
            return wall
          end
        end
        nil
      end
  end
end
