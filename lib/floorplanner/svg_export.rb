module Floorplanner
  module SvgExport
    def to_svg
      # translate to x:0,y:0
      bbox = @walls.bounding_box
      dx = bbox[:min].distance_x(bbox[:max])
      dy = bbox[:min].distance_y(bbox[:max])
      min_x = -bbox[:min].x
      min_y = -bbox[:min].y
      # fit into document dimensions
      width , height , padding = Floorplanner.config['svg']['width'],
                                 Floorplanner.config['svg']['height'],
                                 Floorplanner.config['svg']['padding']
      ratio = ( width < height ? width : height ) * padding / ( dx > dy ? dx : dy )
      # center on stage
      mod_x = min_x + (width /ratio)/2 - dx/2
      mod_y = min_y + (height/ratio)/2 - dy/2

      template = ERB.new(
        File.read(
          File.join(Floorplanner.config['views_path'],'design.svg.erb')))
      template.result(binding)
    end
  end
end
