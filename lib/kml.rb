require 'tmpdir'
require 'rubygems'
require 'zip/zip'
require 'xml'
require 'builder'

$LOAD_PATH.push(File.dirname(__FILE__))

require 'kml/document'
require 'kml/archive'
require 'kml/entities'
require 'kml/geo_point'

module XML
  class Node
    def replace(other_node)
      parent << other_node
      remove!
    end
  end
end
