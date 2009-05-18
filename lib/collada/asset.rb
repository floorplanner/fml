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
      materials = @xml.find(LIBRARY_MATERIALS)
      materials.each {|mat| namespace!(mat)}
      materials
    end

    def library_effects
      effects = @xml.find(LIBRARY_EFFECTS)
      effects.each {|eff| namespace!(eff)}
      effects
    end

    def library_geometries
      geometries = @xml.find(LIBRARY_GEOMETRIES)
      geometries.each{|geo| namespace!(geo)}
      geometries
    end

    def library_visual_scenes
      namespace!(@xml.find(VISUAL_SCENES_QUERY).first)
    end

    private
      def namespace!(node)
        node['id'] = "#{namespace_name}.#{node['id']}" if node['id']
        node['name'] = "#{namespace_name}.#{node['name']}" if node['name']
        node['symbol'] = "#{namespace_name}.#{node['symbol']}" if node['symbol']
        node['material'] = "#{namespace_name}.#{node['material']}" if node['material']


        node['url'] = "##{namespace_name}.#{node['url'].gsub('#','')}" if node['url']
        node['target'] = "##{namespace_name}.#{node['target'].gsub('#','')}" if node['target']
        node['source'] = "##{namespace_name}.#{node['source'].gsub('#','')}" if node['source']

        node.children.each do |children|
          namespace!(children)
        end
        node
      end

      def namespace_name
        self.name.gsub('.','_')
      end

  end
end