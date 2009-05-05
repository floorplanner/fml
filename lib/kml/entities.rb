module KML
  module Entity
    class Placemark < XML::Node
      def initialize(name,author=nil,description=nil,link=nil,visibility=true)
        super('Placemark')
        self << XML::Node.new('name',name.to_s)
        self << XML::Node.new('visibility',visibility ? '1' : '0')
        self << XML::Node.new('atom:link',link.to_s) if link 
        self << XML::Node.new('description',description.to_s) if description
        if author
          author_node = XML::Node.new('atom:author')
          author_node << XML::Node.new('atom:name',author.to_s)
          self << author_node
        end
      end

      def self.from_fml(node)
      end
    end

    class Model < XML::Node
      def initialize(id)
        super('Model')
        self.attributes['id'] = id.to_s
      end

      def self.from_fml(node)
      end
    end

    class Link < XML::Node
      def initialize(href)
        super('Link')
        self << XMl::Node.new('href',href.to_s)
      end

      def self.from_fml(node)
      end
    end

    class Location < XML::Node
      def initialize(lon,lat,alt)
        super('Location')
        self << XML::Node.new('longitude',lon.to_s)
        self << XML::Node.new('latitude', lat.to_s)
        self << XML::Node.new('altitude', alt.to_s)
      end

      def self.from_fml(node)
      end
    end

    class Orientation < XML::Node
      def initialize(heading=0.0,tilt=0.0,roll=0.0)
        super('Orientation')
        self << XML::Node.new('heading',heading.to_s)
        self << XML::Node.new('tilt',tilt.to_s)
        self << XML::Node.new('roll',roll.to_s)
      end

      def self.from_fml(node)
      end
    end

    class Scale < XML::Node
      def initialize(x,y,z)
        super('Scale')
        self << XML::Node.new('x',x.to_s)
        self << XML::Node.new('y',y.to_s)
        self << XML::Node.new('z',z.to_s)
      end

      def self.from_fml(node)
      end
    end

    class LookAt < XML::Node
      def initialize(lon,lat,alt,range,tilt,heading,altitude_mode)
        super('LookAt')
        self << XML::Node.new('longitude',lon.to_s)
        self << XML::Node.new('latitude',lat.to_s)
        self << XML::Node.new('altitude',alt.to_s)
        self << XML::Node.new('range',range.to_s)
        self << XML::Node.new('tilt',tilt.to_s)
        self << XML::Node.new('heading',heading.to_s)
        self << XML::Node.new('altitudeMode',altitude_mode.to_s)
      end

      def self.from_fml(node)
      end
    end

    class Point < XML::Node
      def initialize(lon,lat,alt=nil,altitude_mode=nil)
        super('Point')
        self << XML::Node.new('coordinates',"#{lon.to_s},#{lat.to_s}")
      end

      def self.from_fml(node)
      end
    end
  end
end
