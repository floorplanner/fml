module Geom
  class Polygon < TriangleMesh

    WINDING_CW   = 0
    WINDING_CCW  = 1

    AXIS_X       = 1
    AXIS_Y       = 2
    AXIS_Z       = 3

    CAP_TOP      = 4
    CAP_BASE     = 5
    CAP_BOTH     = 6

    def update
      return false if @vertices.length < 3
      triangles = @triangulation.triangulate(self)
      unless triangles
        @vertices.reverse!
        triangles = @triangulation.triangulate(self)
        return false unless triangles
      end

      triangles.each do |t|
        v0 = @vertices[t[0]]
        v1 = @vertices[t[1]]
        v2 = @vertices[t[2]]
        @faces.push(Triangle.new([v2,v1,v0]))
      end
      true
    end

    def area
      # remove duplicates and invisibles
      return nil if @vertices.length < 3
      @vertices.each{|v| return 0 if @vertices.grep(v).length>1}

      result = 0
      points = @vertices.dup
      plane  = self.plane

      ax = plane.normal.x > 0 ? plane.normal.x : -plane.normal.x
      ay = plane.normal.y > 0 ? plane.normal.y : -plane.normal.y
      az = plane.normal.z > 0 ? plane.normal.z : -plane.normal.z

      coord = AXIS_Z

      if ax > ay
        if ax > az
          coord = AXIS_X
        end
      elsif ay > az
        coord = AXIS_Y
      end

      points.push(points[0],points[1])

      # compute area of the 2D projection
      points.each_with_index do |point,i|
        next if i.zero?
        j = (i+1) % points.length
        k = (i-1) % points.length

        case coord
        when AXIS_X
          result += (point.y * (points[j].z - points[k].z))
        when AXIS_Y
          result += (point.x * (points[j].z - points[k].z))
        else
          result += (point.x * (points[j].y - points[k].y))
        end
      end
              
      # scale to get area before projection
      an = Math.sqrt(ax**2 + ay**2 + az**2) # length of normal vector
      case coord
      when AXIS_X
        result *= (an / (2*ax))
      when AXIS_Y
        result *= (an / (2*ay))
      when AXIS_Z
        result *= (an / (2*az))
      end
      2.times {points.pop}
      result
    end

    # TODO real plane, not just from first 3 vertices
    def plane
      return nil if @vertices.length < 3
      Plane.three_points(*@vertices[0..2])
    end

    def point_inside(pt)
      x = "x"
      y = "y"
      n = @vertices.length
      dominant = dominant_axis
      dist = self.plane.distance(pt)
      result = false
      
      return false if dist.abs > 0.01
      case dominant
      when AXIS_X
        x = "y"
        y = "z"
      when AXIS_Y
        y = "z"
      end

      @vertices.each_with_index do |v,i|
        vn = @vertices[(i+1)%n] # next
        if (((v.send(y) <= pt.send(y)) && (pt.send(y) < vn.send(y))) || ((vn.send(y) <= pt.send(y)) && (pt.send(y) < v.send(y)))) &&
                (pt.send(x) < (vn.send(x) - v.send(x)) * (pt.send(y) - v.send(y)) / (vn.send(y) - v.send(y)) + v.send(x))
          result = !result
        end
      end
      result
    end

    def winding
      area < 0 ? WINDING_CW : WINDING_CCW
    end

    def clone
      vertices = @vertices.collect{|v| v.clone}
      faces    = @faces.collect do |f|
        Triangle.new([
          vertices[ @vertices.index(f.vertices[0]) ],
          vertices[ @vertices.index(f.vertices[1]) ],
          vertices[ @vertices.index(f.vertices[2]) ]
        ])
      end
      Polygon.new(vertices,faces)
    end

    def extrude(distance,direction,cap=CAP_BOTH,update=true)
      direction.normalize
      top_cap = clone
      top_cap.vertices.each do |v|
        v.x += distance*direction.x
        v.y += distance*direction.y
        v.z += distance*direction.z
      end
      top_cap.faces.each {|f| f.normal = direction }
      num = @vertices.length

      sides = Array.new(@vertices.length).map!{ Polygon.new }
      sides.each_with_index do |side,i|
        j = (i+1) % num
        side.vertices.push(top_cap.vertices[i],top_cap.vertices[j])
        side.vertices.push(@vertices[j],@vertices[i])
        side.data[:side] = true
        side.update if update
      end

      case cap
      when CAP_BASE
        top_cap.faces.clear
      when CAP_TOP
        self.faces.clear
      when CAP_BOTH
        self.faces.each do |f|
          f.flip_normal
        end
      end

      sides + [top_cap]
    end

    def dominant_axis
      plane = self.plane
      return 0 unless plane

      ax = (plane.normal.x > 0 ? plane.normal.x : -plane.normal.x)
      ay = (plane.normal.y > 0 ? plane.normal.y : -plane.normal.y)
      az = (plane.normal.z > 0 ? plane.normal.z : -plane.normal.z)

      axis = AXIS_Z
      if ax > ay
        if ax > az
          axis = AXIS_X
        end
      elsif ay > az
        axis = AXIS_Y
      end
      axis
    end
  end
end
