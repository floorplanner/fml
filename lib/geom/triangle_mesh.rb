module Geom
  class TriangleMesh
    attr_accessor(:vertices,:faces,:meshes,:data,:triangulation)
    def initialize(vertices=nil,faces=nil,color="#000000")
      @meshes   = Array.new
      @vertices = vertices || Array.new
      @faces    = faces || Array.new
      @data     = Hash.new
      @triangulation = EarTrim
      @data[:color]  = color # REMOVE
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

    def update
      @meshes.each {|m| m.update}
    end

    def flip_winding
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
  end
end
