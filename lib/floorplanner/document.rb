module Floorplanner

  class Document
    def initialize fml_fn
      @xml = Nokogiri::XML.parse(open(fml_fn))
    end
  end

  class DesignDocument
    def initialize fml
      if fml.kind_of? String # filename
        @xml = Nokogiri::XML.parse(fml)
      elsif fml.kind_of? Nokogiri::XML::Document
        @xml = fml
      elsif fml.respond_to?(:read) # IO
        @xml = Nokogiri::XML.parse(fml)
      else
        raise ArgumentError.new("values must be one of: filename, IO, LibXML::XML::Document")
      end
    end

    def update_heights new_height
      lines = @xml.xpath("/design/lines/line[type='default_wall' or type='normal_wall' or contains(type,'hedge') or contains(type,'fence')]")
      lines.each do |line|
        begin
          points = line.xpath("points").first
          next unless points.content.include? ","

          coords = points.content.strip.split(",")
          top_coords = coords[1].strip.split(/\s/).map(&:to_f)

          top_coords[2] = new_height
          top_coords[5] = new_height
          if top_coords.length > 6
            top_coords[8] = new_height
          end

          coords[1] = top_coords.join(" ")
          points.content = coords.join(",")
        rescue; end
      end
    end

    def update_thumb_2d_url thumb_2d_url
      if thumb_node = @xml.xpath('/design/thumb-2d-url').first
        thumb_node.content = thumb_2d_url
      elsif design_node = @xml.xpath('/design').first
        thumb_node = @xml.create_element('thumb-2d-url')
        thumb_node.content = thumb_2d_url
        design_node << thumb_node
      else
        raise "Cannot update the 2D thumb URL!"
      end
    end

    def save path
      @xml.write_to open(path, 'w')
    end

    def to_xml
      @xml
    end

    def to_s
      @xml.to_s
    end
  end
end
