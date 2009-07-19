module Floorplanner
  class Document

    def to_rib(design_id,out_path)
      @design = Design.new(@xml,design_id)
      @design.build_geometries
      rib = File.new(out_path,'w')
      rib.write @design.to_rib
      rib.close
    end

  end

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
