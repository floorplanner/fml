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

    HEX_RE = "(?i:[a-f\\d])"
    def area(vertices,params=nil)
      a_id = vertices.hash.abs.to_s + "_" +params[:type]
      if params[:color] =~ /\A#((?:#{HEX_RE}{2,2}){3,4})\z/
         params[:color] = [*$1.scan(/.{2,2}/).collect {|value| value.hex / 255.0}]
      else
         params[:color] = [1,1,1]
      end
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
