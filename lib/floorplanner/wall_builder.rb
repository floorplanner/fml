module Floorplanner
  class WallBuilder
    # TODO move to config
    SNAP = 0.01
    def initialize(&block)
      @connections = Hash.new
      @vertices = Array.new
      @walls = Array.new
      block.call(self)
      update
    end

    def vertex(vertex)
      if existing = find_vertex(vertex)
        existing
      else
        @vertices << vertex
        vertex
      end
    end

    def wall(sp,ep,thickness,height)
      @connections[sp] = Array.new unless @connections.include?(sp)
      @connections[ep] = Array.new unless @connections.include?(ep)
      @connections[sp] << {:point => ep, :angle => 0.0}
      @connections[ep] << {:point => sp, :angle => 0.0}
      @walls << Geom::Wall.new(Geom::Edge.new(sp,ep), thickness, height, "wall_#{@walls.length}")
    end

    def getverts
      puts %!<?xml version="1.0" standalone="no"?>
<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="100%"
   height="100%"
   version="1.1"
   id="svg2"
   sodipodi:version="0.32"
   inkscape:version="0.46"
   sodipodi:docname="fofo.svg"
   inkscape:output_extension="org.inkscape.output.svg.inkscape">
  <metadata
     id="metadata39">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
      </cc:Work>
    </rdf:RDF>
  </metadata>
  <defs
     id="defs37">
    <inkscape:perspective
       sodipodi:type="inkscape:persp3d"
       inkscape:vp_x="0 : 0.5 : 1"
       inkscape:vp_y="0 : 1000 : 0"
       inkscape:vp_z="1 : 0.5 : 1"
       inkscape:persp3d-origin="0.5 : 0.33333333 : 1"
       id="perspective41" />
  </defs>
  <sodipodi:namedview
     inkscape:window-height="758"
     inkscape:window-width="1280"
     inkscape:pageshadow="2"
     inkscape:pageopacity="0.0"
     guidetolerance="10.0"
     gridtolerance="10.0"
     objecttolerance="10.0"
     borderopacity="1.0"
     bordercolor="#666666"
     pagecolor="#ffffff"
     id="base"
     showgrid="false"
     showborder="false"
     inkscape:zoom="42.78166"
     inkscape:cx="4.8177591"
     inkscape:cy="1049.4872"
     inkscape:window-x="0"
     inkscape:window-y="20"
     inkscape:current-layer="svg2" />
      !

      @walls.each do |w|
        w.outline.faces.each do |f|
          puts %!
          <polygon points="
            #{f.vertices[0].x},#{f.vertices[0].y}
            #{f.vertices[1].x},#{f.vertices[1].y}
            #{f.vertices[2].x},#{f.vertices[2].y}
          "
style="stroke:rgb(150,99,99);fill:rgb(#{(rand*200).floor},#{(rand*200).floor},#{(rand*200.floor)});stroke-width:0.01;opacity:0.5"/>
        !
        end
      end

      puts %!</svg>!
    end

    private
      def find_wall(sp,ep)
        @walls.each do |wall|
          if wall.baseline.start_point.equal?(sp,SNAP) && wall.baseline.end_point.equal?(ep,SNAP)
            return wall
          elsif wall.baseline.end_point.equal?(sp,SNAP) && wall.baseline.start_point.equal?(ep,SNAP)
            return wall
          end
        end
        nil
      end

      def find_vertex(v)
        @vertices.each do |vertex|
          if v.equal?(vertex,SNAP)
            return vertex
          end
        end
        return nil
      end

      def update
        @vertices.each do |v|
          connections = @connections[v]
          next if connections.length.zero?

          connections.each do |c|
            x = c[:point].x - v.x
            y = c[:point].y - v.y
            c[:angle] = Math.atan2(y,x);
          end
          connections.sort! {|a,b| a[:angle] <=> b[:angle]}
          connections.each_index do |i|
            j = (i+1) % connections.length

            w0 , w1 = find_wall(v,connections[i][:point]),
                      find_wall(v,connections[j][:point])

            flipped0 , flipped1 = (w0.baseline.end_point === v),
                                  (w1.baseline.end_point === v)

            e0 , e1 = flipped0 ? w0.outer : w0.inner,
                      flipped1 ? w1.inner : w1.outer

            isect = Geom::Intersection.line_line(e0.start_point.position,e0.end_point.position,e1.start_point.position,e1.end_point.position,true)

            if isect.status == Geom::Intersection::INTERSECTION
              # the two edges intersect!
              # adjust the edges so they touch at the intersection.
              if isect.alpha[0].abs < 2
                if flipped0
                  e0.end_point.x   = isect.points[0].x
                  e0.end_point.y   = isect.points[0].y
                else
                  e0.start_point.x = isect.points[0].x
                  e0.start_point.y = isect.points[0].y
                end

                if flipped1
                  e1.end_point.x   = isect.points[0].x
                  e1.end_point.y   = isect.points[0].y
                else
                  e1.start_point.x = isect.points[0].x
                  e1.start_point.y = isect.points[0].y
                end
              else
                # parallel
              end
            end
          end
        end

        @walls.each do |w|
          num_start = @connections[w.baseline.start_point].length
          num_end   = @connections[w.baseline.end_point].length
          w.update(num_start,num_end)
        end
      end
  end
end
