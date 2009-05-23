module Geom
  class TriangleMesh3D
    attr_accessor(:vertices,:faces)
    def initialize(vertices=nil,faces=nil)
      @polys    = Array.new
      @vertices = vertices || Array.new
      @faces    = faces || Array.new
    end
  end
end
