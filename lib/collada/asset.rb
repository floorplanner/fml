module Collada
  class Asset
    VISUAL_SCENES_QUERY = '/COLLADA/library_visual_scenes/visual_scene'

    attr_accessor :name

    def initialize(fn)
      @xml = XML::Document.string(File.read(fn).gsub(/xmlns=".+"/, ''))
    end

    def measurement_unit
    end


    def library_materials
    end

    def library_effects
    end

    def library_geometries
    end

    def library_visual_scenes
      scenes = ""

      @xml.find(VISUAL_SCENES_QUERY).each do |visual_scene|
        scenes += visual_scene.to_s
      end
      scenes
    end

  end
end