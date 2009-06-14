require 'erb'
require 'yaml'
require 'find'
require 'open-uri'
require 'net/http'

require 'rubygems'
require 'zip/zip'
require 'xml'

$LOAD_PATH.push(File.dirname(__FILE__))

module Floorplanner
  def self.config
    @@config ||= YAML.load_file(File.join(File.dirname(__FILE__),'config.yml'))
  end
end

require 'geom'
require 'floorplanner/asset'
require 'floorplanner/document'
require 'floorplanner/collada_exporter'
require 'floorplanner/svg_exporter'
require 'floorplanner/design'
require 'floorplanner/wall3d'
require 'floorplanner/opening3d'
require 'floorplanner/wall_builder'
require 'floorplanner/area_builder'
require 'collada/document'
require 'keyhole/archive'

module XML
  class Node
    def get_floats
      content.split(/\s/).map! {|f| f.to_f}
    end
  end
end
