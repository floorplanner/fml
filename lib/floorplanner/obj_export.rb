module Floorplanner
  class Document

    def to_obj(design_id,out_path)
      @design = Design.new(@xml,design_id)
      @design.build_geometries
      obj = File.new(out_path,'w')
      obj.write @design.to_obj
      obj.close
    end

  end

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
