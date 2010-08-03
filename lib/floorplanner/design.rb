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

      heights = Hash.new
      @walls = WallBuilder.new do |b|
        @doc.lines.select{|l| l.type == :default_wall}.each do |line|
          sp = b.vertex(line.vertices[0])
          ep = b.vertex(line.vertices[1])
          b.wall(sp, ep, line.thickness, line.height)

          if heights.include?(line.height)
            heights[line.height] += 1
          else
            heights[line.height] = 1
          end
        end
      end
      # get the most used (common) height accross linears
      @areas.update(heights.sort{|a,b| a[1]<=>b[1]}.last[0]-0.02)

      @walls.prepare
      @doc.openings.each do |opening|
        asset = @doc.asset(opening.asset)
        type  = which_opening(opening, asset)
        @walls.opening(opening.position ,opening.size, type)
      end
      @walls.update
    end

    private

      def which_opening(opening, asset)
        case opening.type
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
