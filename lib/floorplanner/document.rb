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
end
