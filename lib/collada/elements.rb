module Collada
  module Element
    class LinesToVertices
      QUERY = "/dae:COLLADA/dae:library_geometries/dae:geometry/dae:mesh/dae:source[@name='position']/dae:float_array"
      
      def self.from_fml(node)
        floats = node.content.split(/\s/).map! {|f| f.to_f}
        height = node.parent.find('dae:height').first.content.to_f
        thickness = node.parent.find('dae:thickness').first.content.to_f

        # calculate wall's vertices' angles
        half_thickness = thickness/2
        line_tan = Math.atan((floats[1]-floats[4]) / (floats[0]-floats[3]))
        x_diff1 = Math.sin(line_tan)*half_thickness
        y_diff1 = Math.cos(line_tan)*half_thickness

        out_floats = nil
        
        # left to right
        if floats[0] < floats[3]
          out_floats = [
            floats[0]-x_diff1 , floats[1]+y_diff1 , floats[2]+height ,
            floats[3]-x_diff1 , floats[4]+y_diff1 , floats[5]+height ,
            floats[0]+x_diff1 , floats[1]-y_diff1 , floats[2]+height ,
            floats[3]+x_diff1 , floats[4]-y_diff1 , floats[5]+height ,

            floats[0]-x_diff1 , floats[1]+y_diff1 , 0.0 ,
            floats[3]-x_diff1 , floats[4]+y_diff1 , 0.0 ,
            floats[0]+x_diff1 , floats[1]-y_diff1 , 0.0 ,
            floats[3]+x_diff1 , floats[4]-y_diff1 , 0.0
          ]
        else
          out_floats = [
            floats[3]-x_diff1 , floats[4]+y_diff1 , floats[5]+height ,
            floats[0]-x_diff1 , floats[1]+y_diff1 , floats[2]+height ,
            floats[3]+x_diff1 , floats[4]-y_diff1 , floats[5]+height ,
            floats[0]+x_diff1 , floats[1]-y_diff1 , floats[2]+height ,

            floats[3]-x_diff1 , floats[4]+y_diff1 , 0.0 ,
            floats[0]-x_diff1 , floats[1]+y_diff1 , 0.0 ,
            floats[3]+x_diff1 , floats[4]-y_diff1 , 0.0 ,
            floats[0]+x_diff1 , floats[1]-y_diff1 , 0.0
          ]
        end
        node.content = out_floats.join(' ')
      end
    end
  end
end
