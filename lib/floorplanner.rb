require 'erb'
require 'matrix'
require 'rubygems'
require 'zip/zip'
require 'builder'
require 'xml'

$LOAD_PATH.push(File.dirname(__FILE__))

require 'geom'
require 'floorplanner/document'
require 'floorplanner/design'
require 'floorplanner/wall3d'
require 'floorplanner/wall_builder'
require 'floorplanner/area_builder'
require 'collada/document'
require 'collada/asset'
require 'keyhole/archive'

module Floorplanner
  def self.config
    @@config ||= YAML.load_file(File.join(File.dirname(__FILE__),'config.yml'))
  end
end
