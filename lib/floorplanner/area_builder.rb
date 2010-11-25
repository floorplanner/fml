module Floorplanner
  class AreaBuilder < Geom::TriangleMesh

    attr_reader :ceiling_z

    def initialize(&block)
      super()
      @meshes = {}
      block.call(self)
    end

    def each(&block)
      @meshes.each_value{|a| block.call(a)}
    end

    def vertex(p)
      if existing = @vertices.index(p)
        @vertices[existing]
      else
        @vertices << p; p
      end
    end

    def area(vertices, params=nil)
      a_id = vertices.hash.abs.to_s + "_" + params[:type].to_s
      params[:color] = Floorplanner.read_color params[:color]
      @meshes[a_id] = Geom::Polygon.new(vertices, nil, params.merge({:id => a_id}))
    end

    def update(ceiling_z)
      @ceiling_z = ceiling_z
      @meshes.each do |id,mesh|
        mesh.update
      end
    end
  end
end
