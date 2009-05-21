module Geom
  class Edge
    attr_accessor(:start_point,:end_point)
    UP = Number3D.new(0,0,1)
    def initialize(sp,ep)
      @start_point = sp
      @end_point = ep
    end

    def direction
      Number3D.sub(@start_point.position,@end_point.position)
    end

    def length
      x = @end_point.x - @start_point.x;
      y = @end_point.y - @start_point.y;
      z = @end_point.z - @start_point.z;
      Math.sqrt(x*x + y*y + z*z);
    end

    def offset(distance,up=UP)
      edge = self.clone
      dir  = self.direction

      Matrix3D.multiply_vector_3x3(Matrix3D.rotation_matrix(up.x,up.y,up.z, -Math::PI/2),dir)
      dir.normalize

      dir.x *= distance
      dir.y *= distance
      dir.z *= distance

      edge.start_point.x += dir.x
      edge.start_point.y += dir.y
      edge.start_point.z += dir.z
      edge.end_point.x += dir.x
      edge.end_point.y += dir.y
      edge.end_point.z += dir.z

      edge
    end

    def clone
      Edge.new(@start_point.clone,@end_point.clone)
    end

    def to_s
      "#<Geom::Edge:#{@start_point.to_s},#{@end_point.to_s}>"
    end
  end
end
