module Floorplanner
  class AreaBuilder < Geom::TriangleMesh
    def initialize(&block)
      super()
      block.call(self)
      update
    end

    def each(&block)
      @meshes.each{|p| block.call(p)}
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
      @meshes << Geom::Polygon.new(vertices,nil,color)
    end

    private

    def update
      @meshes.each do |m|
        m.update
        @faces.concat(m.faces)
        @vertices.concat(m.vertices)
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
