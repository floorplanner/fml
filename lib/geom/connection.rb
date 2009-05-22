module Geom
  class Connection
    alias_method(:==, :equal?)
    attr_accessor(:point,:angle)
    def initialize(point,angle)
      @point = point
      @angle = angle
    end

    def equal?(other)
      other.point == @point && other.angle == @angle
    end
  end
end
