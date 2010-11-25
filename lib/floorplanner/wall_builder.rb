module Floorplanner
  class WallBuilder < Geom::TriangleMesh

    def initialize(&block)
      super()
      @connections = Hash.new
      @base_vertices = Array.new
      @walls = Array.new
      block.call(self)
    end

    def each(&block)
      @walls.each{|w| block.call(w)}
    end

    def collect(&block)
      @walls.collect{|w| block.call(w)}
    end

    def vertex(vertex)
      if existing = find_vertex(@base_vertices,vertex,Floorplanner.config['geom_snap'])
        existing
      else
        @base_vertices << vertex
        vertex
      end
    end

    def wall(sp, ep, thickness, height)
      @connections[sp] = Array.new unless @connections.include?(sp)
      @connections[ep] = Array.new unless @connections.include?(ep)
      cs = Geom::Connection.new(ep, 0.0)
      ce = Geom::Connection.new(sp, 0.0)
      @connections[sp] << cs unless @connections[sp].include?(cs)
      @connections[ep] << ce unless @connections[ep].include?(ce)
      @walls << Wall3D.new(Geom::Edge.new(sp,ep), thickness, height, "wall_#{@walls.length}")
    end

    # call after adding walls
    def opening(position, size, type)
      @walls.each do |wall|
        if wall.outline.point_inside(position)
          wall.opening(position,size,type)
          break
        end
      end
    end

    def prepare
      @base_vertices.each do |v|
        connections = @connections[v]
        next if connections.length.zero?

        connections.each do |c|
          begin
            c.angle = Math.atan2(c.point.x - v.x, c.point.y - v.y)
          rescue; end
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

      @walls.each do |wall|
        num_start = @connections[wall.baseline.start_point].length
        num_end   = @connections[wall.baseline.end_point].length
        wall.prepare(num_start,num_end)
      end
    end

    def update
      @walls.each do |wall|
        # here comes the cache
        wall.update
        @vertices.concat(wall.vertices)
        @faces.concat(wall.faces)
      end

      $stderr.puts "Walls Vertices before: #{@vertices.length.to_s}"
      # remove same instances
      @vertices.uniq!
      # remove same vertices
      old = @vertices.dup
      @vertices = Array.new
      old.each do |v|
        @vertices.push(v) unless @vertices.include?(v) # find_vertex(@vertices,v) #
      end
      $stderr.puts "Walls Vertices: #{@vertices.length.to_s}"
      $stderr.puts "Walls Faces   : #{@faces.length.to_s}"
    end

    # make use of cache
    def vertices
      @vertices
    end

    def faces
      @faces
    end

    def windows
      @walls.collect{|w| w.windows}.flatten
    end

  private

    def find_wall(sp,ep)
      @walls.each do |wall|
        if wall.baseline.start_point.equal?(sp,Floorplanner.config['geom_snap']) &&
          wall.baseline.end_point.equal?(ep,Floorplanner.config['geom_snap'])
            return wall
        elsif wall.baseline.end_point.equal?(sp,Floorplanner.config['geom_snap']) &&
          wall.baseline.start_point.equal?(ep,Floorplanner.config['geom_snap'])
            return wall
        end
      end
      nil
    end

    def find_vertex(arr,v,snap=Floorplanner.config['uniq_snap'])
      arr.each do |vertex|
        if v.equal?(vertex,snap)
          return vertex
        end
      end
      nil
    end

  end
end
