module Floorplanner
  class Opening3D < Geom::TriangleMesh3D
    OPENING_LOW = 0.85
    def initialize(baseline,thickness,opening)
      super()
      dir = baseline.direction
      pos = opening[:position]
      angle  = Math.atan2(dir.y,dir.x)
      width  = opening[:size].x
      height = opening[:size].y

      v1 = Geom::Vertex3D.new(-width/2,0,0)
      v2 = Geom::Vertex3D.new( width/2,0,0)
      o_base = Geom::Edge.new(v1,v2)
      
      o_base_inner = o_base.offset(thickness/2.0,Wall3D::UP)
      o_base_outer = o_base.offset(-thickness/2.0,Wall3D::UP)

      p = Geom::Polygon3D.new([
        o_base_inner.start_point,o_base_inner.end_point,
        o_base_outer.end_point,o_base_outer.start_point
      ])
      p.transform_vertices(Geom::Matrix3D.rotationZ(angle))
      p.transform_vertices(Geom::Matrix3D.translation(pos.x,pos.y,pos.z+OPENING_LOW))

      extrusion = p.extrude(height,Wall3D::UP,Geom::Polygon3D::CAP_BOTH,false)
      extrusion.delete_at(0)
      extrusion.delete_at(1)
      
      @meshes.concat(extrusion)
      @meshes << p
    end
  end
end
