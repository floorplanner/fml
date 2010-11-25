require 'erb'
require 'yaml'
require 'find'
require 'open-uri'
require 'net/http'
require 'fileutils'

require 'rubygems'
require 'zip/zip'
require 'nokogiri'
require 'roxml'

$LOAD_PATH.push(File.dirname(__FILE__))

module Floorplanner
  def self.config
    @@config ||= YAML.load_file(File.join(File.dirname(__FILE__),'config.yml'))
  end

  def self.config= yaml
    @@config = yaml
  end

  HEX_RE = "(?i:[a-f\\d])"

  def self.read_color hexstring
    if hexstring =~ /\A#((?:#{HEX_RE}{2,2}){3,4})\z/
       return [*$1.scan(/.{2,2}/).collect {|value| value.hex / 255.0}]
    else
       return [1,1,1]
    end
  end
end

require 'geom'
require 'floorplanner/xml'
require 'floorplanner/asset'
require 'floorplanner/document'
require 'floorplanner/collada_export'
require 'floorplanner/svg_export'
require 'floorplanner/design'
require 'floorplanner/wall3d'
require 'floorplanner/opening3d'
require 'floorplanner/wall_builder'
require 'floorplanner/area_builder'
require 'collada/document'
require 'collada/geometry'
require 'keyhole/archive'
