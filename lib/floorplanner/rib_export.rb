module Floorplanner
  module RibExport
    def to_rib
      raise "No geometries to export. Call build_geometries first" unless @areas && @walls

      template = ERB.new(
        File.read(
          File.join(Floorplanner.config['views_path'],'design.rib.erb')))
      template.result(binding)
    end
  end
end
