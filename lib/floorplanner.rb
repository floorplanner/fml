require 'rubygems'
require 'zip/zip'
require 'builder'
require 'xml'

$LOAD_PATH.push(File.dirname(__FILE__))

require 'floorplanner/document'
require 'floorplanner/design'
require 'collada/document'
require 'collada/asset'
require 'keyhole/archive'
require 'geom/number3d'
require 'geom/vertex3d'
require 'geom/intersection'
require 'geom/edge'
require 'geom/wall'

CONFIG = YAML.load_file(File.join(File.dirname(__FILE__),'config.yml'))