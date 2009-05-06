module KML
  class GeoPoint

    LATTITUDE = 110900  # km
    LONGTITUDE = 69290 # km  Variable, dependingon the place


#    Amsterdam  52.373801,4.890935


    attr_accessor :x, :y, :z
    attr_accessor :base_x, :base_y

    def initialize(x,y,z, base_x = '52.373801', base_y = '4.890935')
      @x, @y, @z = x,y,z
      @base_x = base_x
      @base_y = base_y
    end

    def self.from_m(metrs)
      GeoPoint.new(metrs[0], metrs[1], metrs[2])
    end

    def longtitude
      (base_x.to_f + x.to_f / LONGTITUDE)
    end

    def lattitude
      (base_y.to_f + y.to_f / LATTITUDE)
    end

    def height
      100
    end

  end
end