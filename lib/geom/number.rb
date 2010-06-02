module Geom

  class Number3D

    attr_accessor(:x,:y,:z)

    def initialize(x=0,y=0,z=0)
      @x, @y, @z = x, y, z
    end

    def self.sub(v,w)
      Number3D.new(
        v.x - w.x,
        v.y - w.y,
        v.z - w.z
      )
    end

    def self.cross(v,w,target=nil)
      target ||= Number3D.new
      target.reset((w.y * v.z) - (w.z * v.y), (w.z * v.x) - (w.x * v.z), (w.x * v.y) - (w.y * v.x))
      target
    end

    def self.dot(v,w)
      v.x * w.x + v.y * w.y + w.z * v.z
    end

    def self.from_str(str)
      x,y,z = str.split(' ') if str
      str.nil? ? Number3D.new : Number3D.new(x.to_f,y.to_f,z.to_f)
    end

    def reset(nx=nil,ny=nil,nz=nil)
      @x = nx if nx
      @y = ny if ny
      @z = nz if nz
    end

    def normalize
      mod = Math.sqrt( @x**2 + @y**2 + @z**2 )
      if mod != 0 && mod != 1
        mod = 1 / mod # mults are cheaper then divs
        @x *= mod
        @y *= mod
        @z *= mod
      end
    end

    def minus_eq(v)
      @x -= v.x
      @y -= v.y
      @z -= v.z
    end

    def distance_x(other)
      (@x - other.x).abs
    end

    def distance_y(other)
      (@y - other.y).abs
    end

    def distance_z(other)
      (@z - other.z).abs
    end

    def distance(other)
      Math.sqrt(
        distance_z(other) ** 2 +
        Math.sqrt(distance_x(other)**2 + distance_y(other)**2) ** 2
      )
    end

    def hash
      "#{@x}#{@y}#{@z}".hash
    end

    def eql?(other)
      self == other
    end

    def == (other)
      @x == other.x &&
      @y == other.y &&
      @z == other.z
    end

    def to_s
      "#<Geom::Number3D:#{@x},#{@y},#{@z}>"
    end

    def to_floats
      [@x,@y,@z].join ' '
    end
  end

  class NumberUV

    attr_accessor :u, :v

    def initialize(u=0,v=0)
      @u = u
      @v = v
    end

    def clone
      NumberUV.new(u,v)
    end
  end

end
