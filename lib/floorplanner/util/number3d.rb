module Floorplanner
  module Util
    class Number3D
      attr_accessor(:x,:y,:z)
      def initialize(x=0.0,y=0.0,z=0.0)
        @x, @y, @z = x, y, z
      end
    end
  end
end
