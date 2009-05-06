#!/usr/bin/env ruby
require 'lib/kml'
require 'lib/fml'

fml = FML::Document.from_xml(ARGV[0])
kml = KML::Document.new(fml)

puts kml.build
