module Floorplanner
  class Wall3D < Geom::TriangleMesh3D
    UP = Geom::Number3D.new(0,0,1)
    attr_accessor(:baseline,:outline,:inner,:outer,:name)
    def initialize(baseline,thickness,height,name)
      super()
      @baseline = baseline
      @thickness = thickness
      @height = height
      @name = name

      @inner = @baseline.offset(@thickness/2.0,UP)
      @outer = @baseline.offset(-@thickness/2.0,UP)
      @openings = Array.new
    end

    def opening(position,size)
      @openings << {:position => position, :size => size}
    end

    def prepare(num_start_connections,num_end_connections)
      @outline = Geom::Polygon3D.new
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
      @openings.each do |opening|
        op = Opening3D.new(@baseline,@thickness,opening)
        op.update
        @meshes << op
      end
      @outline.update
      @meshes << @outline
      @meshes.concat(@outline.extrude(@height,UP))
    end
  end
end
