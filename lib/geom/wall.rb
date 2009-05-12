module Geom
  class Wall
    attr_accessor(:baseline,:inner,:outer)
    def initialize(baseline,thickness,height,name)
      @baseline = baseline
      @thickness = thickness
      @height = height
      @name = name
    end

    def update_before
      @inner = @baseline.offset(@thickness/2.0)
      @outer = @baseline.offset(-@thickness/2.0)
      @openings = Array.new
    end
  end
end
