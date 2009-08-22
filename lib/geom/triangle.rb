module Geom
  class Triangle

    attr_accessor :vertices, :texcoord, :normal

    def initialize(vertices,texcoord=nil,normal=nil)
      unless vertices.length == 3
        raise "Triangle must consist of exactly 3 vertices"
      end
      @normal   = normal || Number3D.new
      @vertices = vertices
      @texcoord = texcoord
      create_normal
    end

    def flip_normal
      @normal.x = -@normal.x
      @normal.y = -@normal.y
      @normal.z = -@normal.z
    end

    def clone
      Triangle.new(@vertices.collect{|v| v.clone},@texcoord.collect{|uv| uv.clone})
    end

    private
      def create_normal
        vn0 = @vertices[0].position.clone
        vn1 = @vertices[1].position.clone
        vn2 = @vertices[2].position.clone
        vn1.minus_eq(vn0)
        vn2.minus_eq(vn0)
        @normal = Number3D.cross(vn1,vn2,@normal)
        @normal.normalize
      end

  end
end
