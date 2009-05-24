module Floorplanner
  class AreaBuilder < Geom::TriangleMesh3D
    def initialize(&block)
      super()
      block.call(self)
      update
    end

    def each(&block)
      @polys.each{|p| block.call(p)}
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
      @polys << Geom::Polygon3D.new(vertices,nil,color)
    end

    private
      def update
        @polys.each do |p|
          p.update
          @faces.concat(p.faces)
          @vertices.concat(p.vertices)
        end
        # remove same instances
        @vertices.uniq!
        # remove same vertexes
        old = @vertices.dup
        @vertices = Array.new
        old.each do |v|
          @vertices.push(v) unless @vertices.include?(v)
        end
      end

  end
end
