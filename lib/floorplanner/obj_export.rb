module Floorplanner
  module ObjExport
    def to_obj
      raise "No geometries to export. Call build_geometries first" unless @areas && @walls

      template = ERB.new(
        File.read(
          File.join(Floorplanner.config['views_path'],'design.obj.erb')))
      template.result(binding)
    end
  end
end
