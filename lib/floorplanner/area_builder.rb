module Floorplanner
  class AreaBuilder < Geom::TriangleMesh
    def initialize(ceiling_z, &block)
      super()
      @meshes = {}
      block.call(self)
      update ceiling_z
    end

    def each(&block)
      @meshes.each_value{|a| block.call(a)}
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
    def area(vertices,color,type)
      a_id = vertices.hash.abs.to_s + "_" +type
      if color =~ /\A#((?:#{HEX_RE}{2,2}){3,4})\z/
        color = [*$1.scan(/.{2,2}/).collect {|value| value.hex / 255.0}]
      end
      @meshes[a_id] = Geom::Polygon.new(vertices,nil,{:id => a_id, :color => color, :type => type})
    end

    private

    def update(ceiling_z)
      caps = {}
      @meshes.each do |id,mesh|
        mesh.update

        if mesh.data[:type] == "generated_area"
          cap = mesh.clone
          cap.data[:id] = id + "_cap"
          cap.data[:color] = [1.0,1.0,1.0]
          cap.reverse
          cap.transform_vertices(Geom::Matrix3D.translation(0.0,0.0,ceiling_z))

          caps[cap.data[:id]] = cap
        end
      end
      @meshes.merge!(caps)
    end
  end
end
