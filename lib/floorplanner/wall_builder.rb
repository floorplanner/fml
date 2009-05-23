module Floorplanner
  class WallBuilder
    # TODO move to config
    SNAP = 0.01
    def initialize(&block)
      @connections = Hash.new
      @vertices = Array.new
      @walls = Array.new
      block.call(self)
      update
    end

    def vertex(vertex)
      if existing = find_vertex(vertex)
        existing
      else
        @vertices << vertex
        vertex
      end
    end

    def wall(sp,ep,thickness,height)
      @connections[sp] = Array.new unless @connections.include?(sp)
      @connections[ep] = Array.new unless @connections.include?(ep)
      cs = Geom::Connection.new(ep, 0.0)
      ce = Geom::Connection.new(sp, 0.0)
      @connections[sp] << cs unless @connections[sp].include?(cs)
      @connections[ep] << ce unless @connections[ep].include?(ce)
      @walls << Wall3D.new(Geom::Edge.new(sp,ep), thickness, height, "wall_#{@walls.length}")
    end

    def to_svg
      faces = @walls.collect{|w| w.outline.faces}.flatten
      template = ERB.new(File.read('views/outline.svg.erb'))
      template.result(binding)
    end

    private
      def find_wall(sp,ep)
        @walls.each do |wall|
          if wall.baseline.start_point.equal?(sp,SNAP) && wall.baseline.end_point.equal?(ep,SNAP)
            return wall
          elsif wall.baseline.end_point.equal?(sp,SNAP) && wall.baseline.start_point.equal?(ep,SNAP)
            return wall
          end
        end
        nil
      end

      def find_vertex(v)
        @vertices.each do |vertex|
          if v.equal?(vertex,SNAP)
            return vertex
          end
        end
        return nil
      end

      def update
        @vertices.each do |v|
          connections = @connections[v]
          next if connections.length.zero?

          connections.each do |c|
            x = c.point.x - v.x
            y = c.point.y - v.y
            c.angle = Math.atan2(y,x)
          end
          connections.sort! {|a,b| a.angle <=> b.angle}
          connections.each_index do |i|
            j = (i+1) % connections.length

            w0 , w1 = find_wall(v,connections[i].point),
                      find_wall(v,connections[j].point)

            flipped0 , flipped1 = (w0.baseline.end_point == v),
                                  (w1.baseline.end_point == v)

            e0 , e1 = flipped0 ? w0.outer : w0.inner,
                      flipped1 ? w1.inner : w1.outer

            isect = Geom::Intersection.line_line(e0.start_point.position,e0.end_point.position,e1.start_point.position,e1.end_point.position,true)

            if isect.status == Geom::Intersection::INTERSECTION
              # the two edges intersect!
              # adjust the edges so they touch at the intersection.
              if isect.alpha[0].abs < 2
                if flipped0
                  e0.end_point.x   = isect.points[0].x
                  e0.end_point.y   = isect.points[0].y
                else
                  e0.start_point.x = isect.points[0].x
                  e0.start_point.y = isect.points[0].y
                end

                if flipped1
                  e1.end_point.x   = isect.points[0].x
                  e1.end_point.y   = isect.points[0].y
                else
                  e1.start_point.x = isect.points[0].x
                  e1.start_point.y = isect.points[0].y
                end
              else
                # parallel
              end
            end
          end
        end

        @walls.each do |w|
          num_start = @connections[w.baseline.start_point].length
          num_end   = @connections[w.baseline.end_point].length
          w.update(num_start,num_end)
        end
      end
  end
end
