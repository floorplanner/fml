require 'tmpdir'
require 'rubygems'
require 'zip/zip'
require 'xml'
require 'xslt'

$LOAD_PATH.push(File.dirname(__FILE__))

require 'transformable'
require 'kml/document'
require 'kml/archive'
require 'kml/elements'

module XML
  class Node
    def replace(other_node)
      parent << other_node
      remove!
    end
  end
end
