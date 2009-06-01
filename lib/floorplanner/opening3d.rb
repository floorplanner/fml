module Floorplanner
  class Opening3D < Geom::TriangleMesh
    OPENING_LOW = 0.85
    attr_accessor(:position)
    def initialize(baseline,thickness,opening)
      super()
      @position = baseline.snap(opening[:position])
      dir = baseline.direction
      angle  = Math.atan2(dir.y,dir.x)
      width  = opening[:size].x
      height = opening[:size].y

      v1 = Geom::Vertex.new(-width/2,0,0)
      v2 = Geom::Vertex.new( width/2,0,0)
      o_base = Geom::Edge.new(v1,v2)
      
      o_inner = o_base.offset(thickness/2.0,Wall3D::UP)
      o_outer = o_base.offset(-thickness/2.0,Wall3D::UP)

      @base = Geom::Polygon.new([
        o_inner.end_point, o_inner.start_point,
        o_outer.start_point  , o_outer.end_point
      ])

      # rotate in wall's direction
      @base.transform_vertices(Geom::Matrix3D.rotationZ(angle))
      # move to position
      @base.transform_vertices(Geom::Matrix3D.translation(@position.x,@position.y,@position.z+OPENING_LOW))

      extrusion = @base.extrude(height,Wall3D::UP,nil,false)

      # delete sides
      extrusion.delete_at(0)
      extrusion.delete_at(1)

      # flip top cap
      extrusion.last.vertices.reverse!
      
      @meshes << @base
      @meshes.concat(extrusion)
    end

    # drill hole to sides by making 'loop' inside
    # Wall3D's side polygons
    #  
    #        v3.____>____.v4
    #          |         |
    #          ^    ~    v
    #          |         |
    #        v2!____<____!v5
    #          |
    #          v^
    #          |
    #  ..__<___!v1______<____..
    #  
    def drill(poly,outer)
      vers = poly.vertices

      # create loop from extrusion vertices
      v1 = Geom::Vertex.new
      v1.x = @base.vertices[outer ? 0 : 2].x
      v1.y = @base.vertices[outer ? 0 : 2].y

      v2 = @base.vertices[outer ? 0 : 2]
      v3,v4 = nil,nil
      if outer
        v3 = @meshes[2].vertices[outer ? 1 : 0]
        v4 = @meshes[1].vertices[outer ? 0 : 1]
      else
        v3 = @meshes[1].vertices[outer ? 0 : 1]
        v4 = @meshes[2].vertices[outer ? 1 : 0]
      end
      v5 = @base.vertices[outer ? 1 : 3]

      # insert loop
      offset = outer ? vers.length - 4 : 0
      vers.insert(offset+3,v1)
      # vers.insert(offset+4,v2)
      vers.insert(offset+4,v3)
      vers.insert(offset+5,v4)
      vers.insert(offset+6,v5)
      vers.insert(offset+7,v2)
      vers.insert(offset+8,v1)
    end
  end
end
