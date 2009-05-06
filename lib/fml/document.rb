module FML
  class Document

    attr_accessor :xml_document

    def initialize(doc)
      self.xml_document = doc
    end

    def self.from_xml(fn)
      FML::Document.new(XML::Document.file(fn))
    end
    
    def geo_points
      g_p = []
      points.split(',').each do |coord|
        if coord == points.split(',').last
          g_p << KML::GeoPoint.from_m(coord.split(' ')[0..2])
          g_p << KML::GeoPoint.from_m(coord.split(' ')[3..5])
        else
          g_p << KML::GeoPoint.from_m(coord.split(' ')[0..2])
        end
        
      end
      g_p.uniq
    end

    private
    def points
      self.xml_document.find('//project/floors/floor/designs/design/areas/area/points').first.content
    end

  end
end