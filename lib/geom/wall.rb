module Geom
  class Wall
    attr_accessor(:baseline,:outline,:inner,:outer,:name)
    def initialize(baseline,thickness,height,name)
      @baseline = baseline
      @thickness = thickness
      @height = height
      @name = name

      @inner = @baseline.offset(@thickness/2.0)
      @outer = @baseline.offset(-@thickness/2.0)
      @openings = Array.new
    end

    def update(num_start_connections,num_end_connections)
      @outline = Polygon3D.new
      if num_start_connections == 1
        @outline.vertices.push(
          @outer.start_point.clone,
          @inner.start_point.clone)
      else
        @outline.vertices.push(
          @outer.start_point.clone,
          @baseline.start_point.clone,
          @inner.start_point.clone)
      end

      if num_end_connections == 1
        @outline.vertices.push(
          @inner.end_point.clone,
          @outer.end_point.clone)
      else
        @outline.vertices.push(
          @inner.end_point.clone,
          @baseline.end_point.clone,
          @outer.end_point.clone)
      end
      @outline.vertices.reverse!

      if @outline.update
      end
    end
  end
end
