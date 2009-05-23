module Geom
  class Triangle3D
    attr_accessor(:vertices,:face_normal)
    def initialize(poly,vertices)
      unless vertices.length == 3
        raise "Triangle must consist of exactly 3 vertices"
      end
      @face_normal = Number3D.new
      @vertices    = vertices
      create_normal
    end

    private
      def create_normal
        vn0 = @vertices[0].position.clone
        vn1 = @vertices[1].position.clone
        vn2 = @vertices[2].position.clone
        vn1.minus_eq(vn0)
        vn2.minus_eq(vn0)
        @face_normal = Number3D.cross(vn1,vn2,@face_normal)
        @face_normal.normalize
      end

  end
end
