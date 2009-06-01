# 
# Implements "Ear trimming" triangulation algorithm
#
module Geom
  class EarTrim
    def self.triangulate(poly)
      result  = Array.new
      points  = poly.vertices.dup
      num     = points.length
      count   = num*2
      indices = Hash.new

      return [ [0,1,2] ] if num == 3
      points.reverse! if poly.winding == Polygon::WINDING_CW
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

    def self.is_ear(points,u,v,w)
      poly = Polygon.new([points[u],points[v],points[w]])
      return false if poly.area < 0
      points.length.times do |i|
        next if i == u || i == v || i == w
        return false if poly.point_inside(points[i])
      end
      true
    end
  end
end
