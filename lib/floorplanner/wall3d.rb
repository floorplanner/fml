module Floorplanner
  class Wall3D < Geom::TriangleMesh
    UP = Geom::Number3D.new(0,0,1)
    attr_accessor(:baseline,:outline,:inner,:outer,:name)
    def initialize(baseline,thickness,height,name)
      super()
      @baseline  = baseline
      @thickness = thickness
      @height    = height
      @name      = name

      # create inner and outer Edges of wall
      @inner = @baseline.offset(@thickness/2.0,UP)
      @outer = @baseline.offset(-@thickness/2.0,UP)
      @openings = Array.new
    end

    def opening(position,size)
      @openings << {:position => position, :size => size}
    end

    # create base 'outline' polygon of wall
    def prepare(num_start_connections,num_end_connections)
      @outline = Geom::Polygon.new
      if num_start_connections == 1 || num_start_connections == 2
        @outline.vertices.push(
          @outer.start_point,
          @inner.start_point)
      else
        @outline.vertices.push(
          @outer.start_point,
          @baseline.start_point,
          @inner.start_point)
      end

      if num_end_connections == 1 || num_end_connections == 2
        @outline.vertices.push(
          @inner.end_point,
          @outer.end_point)
      else
        @outline.vertices.push(
          @inner.end_point,
          @baseline.end_point,
          @outer.end_point)
      end
      @outline.vertices.reverse!
      @outline.data[:color] = "#ff9999"
    end

    def update
      @openings.each_with_index do |opening,i|
        op = Opening3D.new(@baseline,@thickness,opening)
        op.update
        @meshes << op
        @openings[i] = op
      end
      @openings = @openings.sort_by{|o| o.position.distance(@baseline.start_point.position)}
      @outline.update
      @meshes << @outline

      # create top cap for wall
      top_cap = @outline.clone
      top_cap.transform_vertices(Geom::Matrix3D.translation(0,0,@height))
      @meshes << top_cap

      # create walls side polygons
      num    = @outline.vertices.length
      starts = [@outer.start_point,@inner.start_point,@baseline.start_point]
      ends   = [@outer.end_point,  @inner.end_point,  @baseline.end_point]
      outs   = [@outer.start_point,@outer.end_point]
      @outline.vertices.each_with_index do |v,i|
        j = @outline.vertices[(i+1) % num]
        # omit starting and ending polygons
        next if ( starts.include?(v) && starts.include?(j) ) ||
                ( ends.include?(v) && ends.include?(j) )
        edge = Geom::Edge.new(v,j)
        poly = edge.extrude(@height,UP)
        # drill hole to side
        @openings.each do |opening|
          opening.drill(poly,outs.include?(v))
        end
        poly.update
        poly.flip_winding if @openings.length > 0 && starts.include?(j) && starts.include?(j)
        @meshes << poly
      end
    end
  end
end
