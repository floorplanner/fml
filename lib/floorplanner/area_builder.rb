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

    HEX_RE = "(?i:[a-f\\d])"
    def area(vertices,color)
      a_id = vertices.hash.abs.to_s
      if color =~ /\A#((?:#{HEX_RE}{2,2}){3,4})\z/
        color = [*$1.scan(/.{2,2}/).collect {|value| value.hex / 255.0}]
      end
      @meshes << Geom::Polygon.new(vertices,nil,{:id => a_id, :color => color})
    end

    private

    def update
      @meshes.each do |mesh|
        mesh.update
      end
    end
  end
end
