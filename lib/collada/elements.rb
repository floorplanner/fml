module Collada
  module Element
    class LinesToVertices
      QUERY = "/dae:COLLADA/dae:library_geometries/dae:geometry/dae:mesh/dae:source[@name='position']/dae:float_array"
      
      def self.from_fml(node)
        floats = node.content.split(/\s|\|/).map! {|f| f.to_f}
        height = floats.pop
        thickness = floats.pop

        # calculate wall's vertices here
        half_thickness = thickness/2
        out_floats = [
          floats[0]+half_thickness , floats[1]+half_thickness , floats[2]+height ,
          floats[3]+half_thickness , floats[4]+half_thickness , floats[5]+height ,
          floats[0]-half_thickness , floats[1]-half_thickness , floats[2]+height ,
          floats[3]-half_thickness , floats[4]-half_thickness , floats[5]+height ,

          floats[0]+half_thickness , floats[1]+half_thickness , 0 ,
          floats[3]+half_thickness , floats[4]+half_thickness , 0 ,
          floats[0]-half_thickness , floats[1]-half_thickness , 0 ,
          floats[3]-half_thickness , floats[4]-half_thickness , 0
        ]
        node.content = out_floats.join(' ')
      end
    end
  end
end
