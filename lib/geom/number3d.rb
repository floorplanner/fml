module Geom
  class Number3D
    attr_accessor(:x,:y,:z)
    def initialize(x=0.0,y=0.0,z=0.0)
      @x, @y, @z = x, y, z
    end

    def == (other)
      @x == other.x &&
      @y == other.y &&
      @z == other.z
    end

    def self.sub(v,w)
      Number3D.new(
        v.x - w.x,
        v.y - w.y,
        v.z - w.z
      )
    end
  end
end
