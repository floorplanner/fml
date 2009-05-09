module Collada
  module Element
    class LinesToVertices
      QUERY = "/dae:COLLADA/dae:library_geometries/dae:geometry/dae:mesh/dae:source[@name='position']/dae:float_array"
      
      def self.from_fml(node)
        floats = node.content.split(/\s|\|/).map! {|f| f.to_f}
        height = floats.pop
        thickness = floats.pop

        # calculate wall's vertices here
      end
    end
  end
end
