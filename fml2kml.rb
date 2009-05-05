#!/usr/bin/env ruby
require 'lib/kml'

doc = KML::Document.from_fml(ARGV[0])
puts doc
