require 'forwardable'

module Geom
  class Vertex3D
    attr_accessor(:position)
    extend Forwardable
    def_delegators :@position, :x, :y, :z, :x=, :y=, :z=
    def initialize(x=0.0,y=0.0,z=0.0)
      @position = Number3D.new(x,y,z)
    end

    def == (other)
      @position == other.position
    end

    def equal?(other,snap)
      @position.x-snap < other.x && @position.x+snap > other.x &&
      @position.y-snap < other.y && @position.y+snap > other.y &&
      @position.z-snap < other.z && @position.z+snap > other.z
    end

    def clone
      Vertex3D.new(x,y,z)
    end

    def to_s
      "#<Geom::Vertex3D:#{@position.to_s}>"
    end
  end
end
