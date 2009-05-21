module Geom
  class Intersection
    INTERSECTION    = 1
    NO_INTERSECTION = 0
    attr_accessor(:alpha,:points,:status)
    def initialize(status=NO_INTERSECTION)
      @alpha  = Array.new
      @points = Array.new
      @status = status
    end

    def self.line_line(a1,a2,b1,b2,infinite=true)
      result = Intersection.new

      x1, y1 = a1.x, a1.y
      x2, y2 = a2.x, a2.y
      x3, y3 = b1.x, b1.y
      x4, y4 = b2.x, b2.y

      d = ((y4-y3)*(x2-x1)-(x4-x3)*(y2-y1))

      unless d.zero?
        # The lines intersect at a point somewhere
        ua = ((x4-x3)*(y1-y3)-(y4-y3)*(x1-x3)) / d
        ub = ((x2-x1)*(y1-y3)-(y2-y1)*(x1-x3)) / d
        
        result.alpha.push(ua,ub)
        if infinite || ((ua > 0 && ua < 1) && (ub > 0 && ub < 1))
          x = x1 + ua*(x2-x1);
          y = y1 + ua*(y2-y1);
          result.points << Number3D.new(x,y)
          result.status = INTERSECTION;
        end
      end
      result
    end
  end
end
