module Geom
  class TriangleMesh3D
    attr_accessor(:vertices,:faces,:polys,:color)
    def initialize(vertices=nil,faces=nil,color="#cccccc")
      @polys    = Array.new
      @vertices = vertices || Array.new
      @faces    = faces || Array.new
      @color    = color
    end
  end
end
