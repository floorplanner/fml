module Floorplanner
  class Document
    ASSETS_QUERY  = "/project/floors/floor/designs/design[id='%s']/assets/asset"
    OBJECTS_QUERY = "/project/floors/floor/designs/design[id='%s']/objects/object"
    POINTS_QUERY  = "/project/floors/floor/designs/design/area/line/points"
    LINE_POINTS_REGEXP = /^((\s*[-+]?[0-9]*\.?[0-9]+\s+){5,8}\s*[-+]?[0-9]*\.?[0-9]+\s*?(?:,)?)*$/

    def initialize(fml_fn,design_id)
      @xml = XML::Document.file(fml_fn)
      @design = Floorplanner::Design.new(@xml,design_id)
      @design_id = design_id
    end

    def self.validate(doc)
      schema = XML::RelaxNG.document(
        XML::Document.file(Floorplanner.config['fml_schema'])
      )
      doc = XML::Document.file(doc) if doc.instance_of?(String)
      doc.validate_relaxng(schema) do |message,error|
        # throw an exception in the name of love
        puts message if error
      end
    end

    def to_dae
      @design.build_geometries

      @walls = @design.walls
      @areas = @design.areas

      # somehow...
      @walls.reverse
      @areas.each {|a| a.reverse}

      @elements = objects
      template = ERB.new(
        File.read(
          File.join(Floorplanner.config['views_path'],'design.dae.erb')))
      template.result(binding)
    end

    private

    def assets
      return @assets if @assets
      @assets = {}
      @xml.find(ASSETS_QUERY % @design_id).each do |asset_node|
        url3d = asset_node.find('url3d')
        asset_id = asset_node.attributes['id']
        next if url3d.empty?

        asset = Floorplanner::Asset.get(asset_id, url3d.first.content)
        next unless asset
        @assets.store(asset_id, asset)
      end
      @assets
    end

    def objects
      result = []
      @xml.find(OBJECTS_QUERY % @design_id).each do |object|
        refid = object.find('asset').first.attributes['refid']
        next unless assets[refid]

        points   = object.find('points').first.content

        rotation = unless object.find('rotation').empty?
          object.find('rotation').first.content
        else
          '0 0 0'
        end
          
        asset    = assets[refid]
        size     = object.find('size').first.content
        scale    = asset.scale_ratio(Geom::Number3D.from_str(size))
        mirrored = object.find('mirrored').first
        reflection = Geom::Matrix3D.identity
        if mirrored
          mirror   = Geom::Number3D.from_str(mirrored)
          if mirror.x != 0 || mirror.y != 0 || mirror.z != 0
            mirror.x = mirror.x > 0 ? 1 : 0
            mirror.y = mirror.y > 0 ? 1 : 0
            mirror.z = mirror.z > 0 ? 1 : 0

            origin = Geom::Number3D.new
            plane  = Geom::Plane.new(mirror,origin)
            reflection = Geom::Matrix3D.reflection(plane)
          end
        end

        result << {
          :asset => asset,
          :position => Geom::Number3D.from_str(points),
          :rotation => Geom::Number3D.from_str(rotation),
          :scale    => scale,
          :matrix   => reflection
        }
      end
      result
    end

    def self.validate_line_points(doc)
      doc.find(POINTS_QUERY).each do |points_node|
        unless LINE_POINTS_REGEXP =~ points_node.children.to_s
          # throw an exception in the name of love
          puts "Elements points inside area's line failed to validate content."
        end
      end
    end
  end
end
