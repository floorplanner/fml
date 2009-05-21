module Geom
  class Plane3D
    attr_accessor(:normal)
    def initialize(normal=nil,point=nil)
      if normal && point
        @normal = normal
        @d      = -Number3D.new(normal,point)
      else
        @normal = Number3D.new
        @d      = 0
      end
    end

    def self.three_points(p0,p1,p2)
      plane = Plane3D.new
      n0 = p0.instance_of?(Number3D) ? p0 : p0.position
      n1 = p1.instance_of?(Number3D) ? p1 : p1.position
      n2 = p2.instance_of?(Number3D) ? p2 : p2.position
      plane.set_three_points(p0,p1,p2)
      plane
    end

    def set_three_points(p0,p1,p2)
      ab = Number3D.sub(p1,p0)
      ac = Number3D.sub(p2,p0)
      @normal = Number3D.cross(ab,ac)
      @normal.normalize
      @d = Number3D.dot(@normal,p0)
    end

    def distance(pt)
      p = pt.instance_of?(Vertex3D) ? pt.position : pt
      Number3D.dot(p,@normal) + @d
    end
  end
end
