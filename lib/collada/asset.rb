module Collada
  class Asset
    VISUAL_SCENES_QUERY = '/COLLADA/library_visual_scenes/visual_scene/node'
    LIBRARY_GEOMETRIES = '/COLLADA/library_geometries/geometry'
    LIBRARY_EFFECTS = '/COLLADA/library_effects/effect'
    LIBRARY_MATERIALS = '/COLLADA/library_materials/material'

    attr_accessor :name

    def initialize(fn)
      @xml = XML::Document.string(File.read(fn).gsub(/xmlns=".+"/, ''))
      self.name = File.basename(fn)
    end

    def measurement_unit
    end

    def library_materials
      @xml.find(LIBRARY_MATERIALS)
    end

    def library_effects
      @xml.find(LIBRARY_EFFECTS)
    end

    def library_geometries
      @xml.find(LIBRARY_GEOMETRIES)
    end

    def library_visual_scenes
      @xml.find(VISUAL_SCENES_QUERY).first
    end

  end
end