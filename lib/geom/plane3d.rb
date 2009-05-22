module Geom
  class Plane3D
    attr_accessor(:normal)
    def initialize(normal=nil,point=nil)
      if normal && point
        @normal = normal
        @d      = -Number3D.dot(normal,point)
      else
        @normal = Number3D.new
        @d      = 0
      end
    end

    def self.three_points(p0,p1,p2)
      plane = Plane3D.new
      n0 = p0.instance_of?(Number3D) ? p0 : p0.position.clone
      n1 = p1.instance_of?(Number3D) ? p1 : p1.position.clone
      n2 = p2.instance_of?(Number3D) ? p2 : p2.position.clone
      plane.set_three_points(n0,n1,n2)
      plane
    end

    def set_three_points(p0,p1,p2)
      ab = Number3D.sub(p1,p0)
      ac = Number3D.sub(p2,p0)
      @normal = Number3D.cross(ab,ac)
      @normal.normalize
      @d = -Number3D.dot(@normal,p0)
    end

    def distance(point)
      p = point.instance_of?(Vertex3D) ? point.position : point
      Number3D.dot(p,@normal) + @d
    end
  end
end
