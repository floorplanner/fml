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

    def self.from_str(str)
      x,y,z = str.split(' ') if str
      str.nil? ? Number3D.new : Number3D.new(x.to_f,y.to_f,z.to_f)
    end
  end
end
