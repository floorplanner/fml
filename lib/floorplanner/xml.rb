module Floorplanner::ROXML

  class Asset
    include ROXML

    xml_accessor :id, :from => :attr
    xml_accessor :name
    xml_accessor :url2d
    xml_accessor :url3d
  end

  class Line
    include ROXML

    xml_accessor :points
    xml_accessor :type_str, :from => 'type'
    xml_accessor :asset, :from => 'asset/@refid'

    def type
      type_str.to_sym
    end
    
    def vertices
      @vertices ||= Floorplanner::XML.parse_points(points)
    end
  end

  class Area
    include ROXML

    xml_accessor :type_str
    xml_accessor :points

    def type
      type_str.to_sym
    end

    def vertices
      @vertices ||= Floorplanner::XML.parse_points(points)
    end
  end

  class Item
    include ROXML

    xml_accessor :asset, :from => 'asset/@refid'
    xml_accessor :type_str, :from => 'type'
    xml_accessor :color

    xml_accessor :size
    xml_accessor :points
    xml_accessor :rotation_str, :from => 'rotation'

    def type
      type_str.to_sym
    end

    def scale
      @scale ||= Floorplanner::XML.parse_vector(size)
    end

    def position
      @position ||= Floorplanner::XML.parse_vector(points)
    end

    def rotation
      @rotation ||= Floorplanner::XML.parse_vector(rotation_str)
    end
  end

  class Document
    include ROXML

    xml_accessor :name
    xml_accessor :assets,  :as => [Asset], :from => 'assets'
    xml_accessor :lines,   :as => [Line]
    xml_accessor :areas,   :as => [Area]
    xml_accessor :objects, :as => [Item]

    def asset(refid)
      assets.detect { |a| a.id == refid }
    end
  end

  protected

    def self.parse_vector(val)
      Geom::Vertex.new(*val.split(/\s/).map{ |s| s.to_f })
    rescue
      nil
    end

    def self.parse_points(val)
      points = val.split(/\s|,/)
      raise "Invalid coords. count for points" unless points.length % 3 == 0

      result = []
      points.each_with_index do |x,i|
        result << [] if i % 3 == 0
        result.last << x.to_f
      end
      result.map { |f| Geom::Vertex.new(*f) }
    end
end

