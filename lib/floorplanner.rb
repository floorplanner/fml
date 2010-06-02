require 'erb'
require 'yaml'
require 'find'
require 'open-uri'
require 'net/http'
require 'fileutils'

require 'rubygems'
require 'zip/zip'
require 'roxml'
require 'xml'

$LOAD_PATH.push(File.dirname(__FILE__))

module Floorplanner
  def self.config
    @@config ||= YAML.load_file(File.join(File.dirname(__FILE__),'config.yml'))
  end

  def self.config=(yaml)
    @@config = yaml
  end
end

module XML
  class Node
    def get_floats
      content.split(/\s|,/).delete_if {|s| s.empty?}.map! {|f| f.to_f}
    end
  end
end

require 'geom'
require 'floorplanner/xml'
require 'floorplanner/asset'
require 'floorplanner/document'
require 'floorplanner/collada_export'
require 'floorplanner/rib_export'
require 'floorplanner/obj_export'
require 'floorplanner/svg_export'
require 'floorplanner/design'
require 'floorplanner/wall3d'
require 'floorplanner/opening3d'
require 'floorplanner/wall_builder'
require 'floorplanner/area_builder'
require 'collada/document'
require 'collada/geometry'
require 'keyhole/archive'
