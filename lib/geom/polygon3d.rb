module Geom
  class Polygon3D < TriangleMesh3D

    WINDING_CW   = 0
    WINDING_CCW  = 1

    AXIS_X       = 1
    AXIS_Y       = 2
    AXIS_Z       = 3

    attr_accessor(:vertices,:faces)

    def update
      return false if @vertices.length < 3
      triangles = triangulate
      unless triangles
        @vertices.reverse!
        triangles = triangulate
        return false unless triangles
      end

      triangles.each do |t|
        v0 = @vertices[t[0]]
        v1 = @vertices[t[1]]
        v2 = @vertices[t[2]]
        @faces.push(Triangle3D.new(self,[v2,v1,v0]))
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

    def plane
      return nil if @vertices.length < 3
      Plane3D.three_points(*@vertices[0..2])
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

    private
      def triangulate
        result  = Array.new
        points  = @vertices.dup
        num     = points.length
        count   = num*2
        indices = Hash.new

        points.reverse! if winding == WINDING_CW
        return [ [0,1,2] ] if num == 3
        points.each_with_index do |p,i|
          indices[p] = i
        end

        while num > 2
          return nil if count > num*2 # overflow
          count += 1

          i = 0
          while i < num 
            j = (i+num-1) % num
            k = (i+1) % num

            if is_ear(points,j,i,k)
              # save triangle
              result.push([indices[points[j]],indices[points[i]],indices[points[k]]])
              # remove vertex
              points.delete_at(i)
              num = points.length
              count = 0
            end
            i += 1
          end
        end
        result
      end

      def is_ear(points,u,v,w)
        poly = Polygon3D.new([points[u],points[v],points[w]])
        return false if poly.area <= 0
        points.length.times do |i|
          next if i == u || i == v || i == w
          return false if poly.point_inside(points[i])
        end
        true
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
