#!/usr/bin/env ruby
require 'lib/kml'
require 'lib/collada'

if !ARGV[0]
  puts "Usage: fml2kml.rb <FML file> > <walls collada>"
else
  dae = Collada::Document.from_fml(ARGV[0])
  puts dae.values.first
end
