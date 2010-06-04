module Floorplanner::XML

  class Asset
    include ROXML

    xml_accessor :id, :from => :attr
    xml_accessor :name
    xml_accessor :url2d
    xml_accessor :url3d
  end

  class Line
    include ROXML

    DEFAULT_HEIGHT = 2.4

    xml_accessor :points
    xml_accessor :type_str, :from => 'type'
    xml_accessor :asset, :from => 'asset/@refid'
    xml_accessor :thickness_str, :from => 'thickness'
    xml_accessor :height_str, :from => 'height'

    def type
      type_str.to_sym
    end

    def height
      height_str ? height_str.to_f : (
        vertices[3] ? vertices[3].z : DEFAULT_HEIGHT)
    end

    def thickness
      thickness_str.to_f
    end
    
    def vertices
      @vertices ||= Floorplanner::XML.parse_points(points)
    end
  end

  class Area
    include ROXML

    xml_accessor :type_str
    xml_accessor :points
    xml_accessor :color
    xml_accessor :name
    xml_accessor :asset, :from => 'asset/@refid'

    def type
      type_str.to_sym if type_str
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

    xml_accessor :points
    xml_accessor :size_str, :from => 'size'
    xml_accessor :rotation_str, :from => 'rotation'
    xml_accessor :mirrored_str, :from => 'mirrored'

    def type
      type_str.to_sym
    end

    def size
      @scale ||= Floorplanner::XML.parse_vector(size_str)
    end

    def position
      @position ||= Floorplanner::XML.parse_point(points)
    end

    def rotation
      @rotation ||= Floorplanner::XML.parse_rotation(rotation_str)
    end

    def mirrored
      @mirrored ||= Floorplanner::XML.parse_vector(mirrored_str)
    end
  end

  class Document
    include ROXML

    xml_accessor :name
    xml_accessor :assets,   :as => [Asset]
    xml_accessor :lines,    :as => [Line]
    xml_accessor :areas,    :as => [Area]
    xml_accessor :objects,  :as => [Item]
    xml_accessor :openings, :as => [Item], 
      :from => "objects/object[(type='opening') or (type='window') or (type='door')]"

    def asset(refid)
      assets.detect { |a| a.id == refid }
    end
  end

  protected

    # We are inverting Y coordinate here because of Flash
    # inverted coordinate system

    def self.parse_point(val)
      f = val.split(/\s/).map{ |s| s.to_f }
      Geom::Vertex.new(f[0], -f[1], f[2])
    rescue
      nil
    end

    # Inverting Z rotation (Flash again)

    def self.parse_rotation(val)
      f = val.split(/\s/).map{ |s| s.to_f }
      Geom::Vertex.new(f[0], f[1], -f[2])
    rescue
      nil
    end

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
      result.map { |f| Geom::Vertex.new(f[0], -f[1], f[2]) }
    end
end

