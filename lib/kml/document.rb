module KML
  class Document

    attr_accessor :geo_points

    def initialize(fml)
      self.geo_points = fml.geo_points
    end

    def build
      @xml = Builder::XmlMarkup.new(:indent => 1)
      @xml.instruct!

      output = @xml.Placemark do
        @xml.name 'Some name'
        @xml.Polygon do
          @xml.extrude 1
          @xml.altitudeMode 'relativeToGround'
          @xml.outerBoundaryIs do
            @xml.LinearRing do
              @xml.coordinates points_string
            end
          end
        end
      end

      output
    end

    def points_string
      string = ""
      self.geo_points.each do |point|
        string += "#{point.lattitude},#{point.longtitude},#{point.height}\n"
      end
      string
    end
    
  end
end
