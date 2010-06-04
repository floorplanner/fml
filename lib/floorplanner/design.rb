module Floorplanner
  class Design

    include ColladaExport
    include SvgExport

    ##
    # Constructs new floorplan design from FML
    ##
    def initialize(doc)
      @doc = doc
    end

    ##
    # Builds geometries of walls and areas.
    ##
    def build_geometries
      @areas = AreaBuilder.new do |b|
        @doc.areas.each do |area|
          if area.asset
            texture_url = @doc.asset(area.asset).url2d
          end

          b.area(area.vertices,
            :color   => area.color,
            :name    => area.name,
            :texture => texture_url,
            :type    => area.type)
        end
      end

      min_height = 10
      @walls = WallBuilder.new do |b|
        @doc.lines.each do |line|
          sp = b.vertex(line.vertices[0])
          ep = b.vertex(line.vertices[1])
          b.wall(sp, ep, line.thickness, line.height)

          min_height = line.height if line.height < min_height
        end
      end
      @areas.update min_height

      @walls.prepare
      @doc.openings.each do |opening|
        asset = @doc.asset(opening.asset)
        type  = which_opening(opening, asset)
        @walls.opening(opening.position ,opening.size, type)
      end
      @walls.update
    end

    private

      def which_opening(type, asset)
        case 
        when :door
          type = Opening3D::TYPE_DOOR
        when :window
          type = Opening3D::TYPE_WINDOW
        else
          type = asset.url2d.match(/door/i) ? 
            Opening3D::TYPE_DOOR : Opening3D::TYPE_WINDOW
        end
        type
      end
  end
end
