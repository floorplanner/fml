module Geom
  class Edge
    attr_accessor(:start_point,:end_point)
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

    def offset(distance,up)
      up.normalize
      edge = clone
      dir  = direction

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

    def extrude(distance,direction)
      edge = clone
      [edge.start_point,edge.end_point].each do |v|
        v.x += distance*direction.x
        v.y += distance*direction.y
        v.z += distance*direction.z
      end

      poly = Polygon.new
      poly.vertices.push(
        edge.end_point , edge.start_point,
        @start_point   , @end_point)
      poly
    end

    def snap(point)
      point
    end

    def clone
      Edge.new(@start_point.clone,@end_point.clone)
    end

    def to_s
      "#<Geom::Edge:#{@start_point.to_s},#{@end_point.to_s}>"
    end
  end
end
