module Floorplanner

  class Document
    POINTS_QUERY = "/project/floors/floor/designs/design/area/line/points"
    LINE_POINTS_REGEXP = /^((\s*[-+]?[0-9]*\.?[0-9]+\s+){5,8}\s*[-+]?[0-9]*\.?[0-9]+\s*?(?:,)?)*$/

    def initialize(fml_fn)
      @xml = XML::Document.file(fml_fn)
    end

    def self.validate(doc)
      schema = XML::RelaxNG.document(
        XML::Document.file(File.join(File.dirname(__FILE__), "..", "..", "xml", "fml.rng"))
      )
      doc = XML::Document.file(doc) if doc.instance_of?(String)
      doc.validate_relaxng(schema) do |message,error|
        # TODO throw an exception
        puts message if error
      end
    end

  private

    def self.validate_line_points(doc)
      doc.find(POINTS_QUERY).each do |points_node|
        unless LINE_POINTS_REGEXP =~ points_node.children.to_s
          # TODO throw an exception
          puts "Elements points inside area's line failed to validate content."
        end
      end
    end
  end

  class DesignDocument
    def initialize(fml_fn)
      @xml = XML::Document.file(fml_fn)
    end

    def update_heights(new_height)
      lines = @xml.find("/design/lines/line[type='default_wall' or type='normal_wall' or contains(type,'hedge') or contains(type,'fence')]")
      lines.each do |line|
        begin
          points = line.find("points").first
          next unless points.content.include? ","

          coords = points.content.strip.split(",")
          top_coords = coords[1].strip.split(/\s/).map{|c| c.to_f}

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

    def save(fn)
      @xml.save fn
    end
  end

end
