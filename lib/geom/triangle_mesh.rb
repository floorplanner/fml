module Geom
  class TriangleMesh

    attr_accessor(:vertices,:texcoord,:faces,:meshes,:data,:tess)

    def initialize( vertices=nil, faces=nil, user_data=nil )
      @data     = user_data || Hash.new
      @faces    = faces     || Array.new
      @vertices = vertices  || Array.new
      @meshes   = Array.new

      @tess     = EarTrim
    end

    def << (mesh)
      @meshes << mesh
    end

    def vertices
      result = @meshes.collect {|m| m.vertices}.flatten
      result.empty? ? @vertices : result
    end

    def faces
      result = @meshes.collect {|m| m.faces}.flatten
      result.empty? ? @faces : result
    end

    def texcoord
      result = @meshes.collect {|m| m.texcoord}.flatten
      result.empty? ? @texcoord : result
    end

    def update
      @meshes.each {|m| m.update}
    end

    def reverse
      faces.each {|f| f.vertices.reverse! }
    end

    def transform_vertices(transformation)
      ta = transformation.to_a
      m11 = ta[0][0]
      m12 = ta[0][1]
      m13 = ta[0][2]
      m21 = ta[1][0]
      m22 = ta[1][1]
      m23 = ta[1][2]
      m31 = ta[2][0]
      m32 = ta[2][1]
      m33 = ta[2][2]

      m14 = ta[0][3]
      m24 = ta[1][3]
      m34 = ta[2][3]

      @vertices.each do |v|
        vx = v.x
        vy = v.y
        vz = v.z

        tx = vx * m11 + vy * m12 + vz * m13 + m14
        ty = vx * m21 + vy * m22 + vz * m23 + m24
        tz = vx * m31 + vy * m32 + vz * m33 + m34

        v.x = tx
        v.y = ty
        v.z = tz
      end
    end

    def bounding_box
      min = Geom::Number3D.new( 1000, 1000, 1000)
      max = Geom::Number3D.new(-1000,-1000,-1000)

      vertices.each do |v|
        min.x = v.x if v.x < min.x
        min.y = v.y if v.y < min.y
        min.z = v.z if v.z < min.z

        max.x = v.x if v.x > max.x
        max.y = v.y if v.y > max.y
        max.z = v.z if v.z > max.z
      end

      { :max => max , :min => min }
    end

    def merge(other)
      @vertices.concat other.vertices
    end
  end
end
