module Geom
  class TriangleMesh3D
    attr_accessor(:vertices,:faces,:meshes,:color)
    def initialize(vertices=nil,faces=nil,color="#000000")
      @meshes   = Array.new
      @vertices = vertices || Array.new
      @faces    = faces || Array.new
      @color    = color
    end

    def << (mesh)
      @meshes = mesh
    end

    def vertices
      result = @meshes.collect{|m| m.vertices}.flatten
      result.empty? ? @vertices : result
    end

    def faces
      result = @meshes.collect{|m| m.faces}.flatten
      result.empty? ? @faces : result
    end
  end
end
