module Floorplanner
  class AreaBuilder < Geom::TriangleMesh3D
    def initialize(&block)
      super()
      block.call(self)
    end

    def vertex(v)
      if existing = @vertices.index(v)
        @vertices[existing]
      else
        @vertices << v
        v
      end
    end

    def area(vertices,color)
      vertices.each{|v| puts v}
      p = Geom::Polygon3D.new(vertices,nil,color)
      p.update
      @polys << p
    end
  end
end
