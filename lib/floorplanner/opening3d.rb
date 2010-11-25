module Floorplanner
  class Opening3D < Geom::TriangleMesh

    TYPE_DOOR   = 1
    TYPE_WINDOW = 2

    attr_accessor(:position,:window)

    def initialize(baseline,thickness,opening)
      super()
      base_z    = opening[:position].z
      @position = baseline.snap(opening[:position])
      @type     = opening[:type]
      @size     = opening[:size]
      dir = baseline.direction
      angle  = Math.atan2(dir.y,dir.x)
      width  = opening[:size].x

      case @type
      when TYPE_DOOR
        @position.z = 0.01
        height = @size.z == 0 ? Floorplanner.config['openings']['door_height'] : @size.z
      else
        @position.z = base_z == 0 ? Floorplanner.config['openings']['window_base'] : base_z
        height = @size.z == 0 ? Floorplanner.config['openings']['window_height'] : @size.z
      end

      v1 = Geom::Vertex.new(-width/2,0,0)
      v2 = Geom::Vertex.new( width/2,0,0)
      o_base = Geom::Edge.new(v1,v2)

      # create opening side
      o_inner = o_base.offset(thickness/2.0,Wall3D::UP)
      o_outer = o_base.offset(-thickness/2.0,Wall3D::UP)

      @base = Geom::Polygon.new([
        o_inner.end_point, o_inner.start_point,
        o_outer.start_point  , o_outer.end_point
      ])

      # rotate in wall's direction
      @base.transform_vertices(Geom::Matrix3D.rotationZ(angle))
      # move to position
      @base.transform_vertices(Geom::Matrix3D.translation(@position.x,@position.y,@position.z))

      extrusion = @base.extrude(height,Wall3D::UP,nil,false)

      # delete sides
      extrusion.delete_at(0)
      extrusion.delete_at(1)

      # flip top cap
      extrusion.last.reverse

      @meshes << @base
      @meshes.concat(extrusion)

      # create glass
      if @type == TYPE_WINDOW
        g_inner = o_base.offset( 0.02, Wall3D::UP)
        g_outer = o_base.offset(-0.02, Wall3D::UP)

        glass_base = Geom::Polygon.new([
          g_inner.end_point, g_inner.start_point,
          g_outer.start_point  , g_outer.end_point
        ])

        # rotate in wall's direction
        glass_base.transform_vertices(Geom::Matrix3D.rotationZ(angle))
        # move to position
        glass_base.transform_vertices(Geom::Matrix3D.translation(@position.x,@position.y,@position.z))

        extrusion = glass_base.extrude(height,Wall3D::UP,nil,false)

        # flip base cap
        glass_base.reverse

        @window = Geom::TriangleMesh.new
        @window.meshes.concat extrusion
        @window << glass_base
        @window.update
      end
    end

    # drill hole to sides
    def drill(mesh,outer)
      side = outer ? mesh.meshes.first : mesh.meshes.last

      # opening start
      t1   = @meshes.first.vertices[outer ? 0 : 3].clone
      t1.z = side.vertices[0].z
      t1b  = @meshes[3].vertices[outer ? 0 : 3]

      b1   = @meshes.first.vertices[outer ? 0 : 3].clone
      b1.z = side.vertices[2].z
      b1t  = @meshes.first.vertices[outer ? 0 : 3]

      # opening end
      t2   = @meshes.first.vertices[outer ? 1 : 2].clone
      t2.z = side.vertices[0].z
      t2b  = @meshes[3].vertices[outer ? 1 : 2]

      b2   = @meshes.first.vertices[outer ? 1 : 2].clone
      b2.z = side.vertices[2].z
      b2t  = @meshes.first.vertices[outer ? 1 : 2]

      # old side vertices
      ot = side.vertices[1]
      ob = side.vertices[2]
      side.vertices[1] = outer ? t2 : t1
      side.vertices[2] = outer ? b2 : b1

      # polygon above opening
      op_top = Geom::Polygon.new
      if outer
        op_top.vertices.push(t2,t1,t1b,t2b)
      else
        op_top.vertices.push(t1,t2,t2b,t1b)
      end

      # polygon below opening
      op_bot = Geom::Polygon.new
      if outer
        op_bot.vertices.push(b2t,b1t,b1,b2)
      else
        op_bot.vertices.push(b1t,b2t,b2,b1)
      end

      rest = Geom::Polygon.new
      if outer
        rest.vertices.push(t1,ot,ob,b1)
      else
        rest.vertices.push(t2,ot,ob,b2)
      end

      mesh.meshes.push(op_top)
      mesh.meshes.push(op_bot)
      mesh.meshes.push(rest)
    end
  end
end
