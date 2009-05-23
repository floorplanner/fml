module Floorplanner
  class Wall3D < Geom::TriangleMesh3D
    attr_accessor(:baseline,:outline,:inner,:outer,:name)
    def initialize(baseline,thickness,height,name)
      super()
      @baseline = baseline
      @thickness = thickness
      @height = height
      @name = name

      @inner = @baseline.offset(@thickness/2.0)
      @outer = @baseline.offset(-@thickness/2.0)
      @openings = Array.new
      @extrusion = nil
    end

    def update(num_start_connections,num_end_connections)
      @outline = Geom::Polygon3D.new
      if num_start_connections == 2
        @outline.vertices.push(
          @outer.start_point,
          @inner.start_point)
      else
        @outline.vertices.push(
          @outer.start_point,
          @baseline.start_point,
          @inner.start_point)
      end

      if num_end_connections == 2
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

      if @outline.update
        @extrusion = @outline.extrude(@height)
      end
    end

    def vertices
      @outline.vertices
    end

    def faces
      @outline.faces + @extrusion.collect{|f| f.faces}.flatten
    end
  end
end
