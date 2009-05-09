#!/usr/bin/env ruby
require 'lib/kml'
require 'lib/collada'

if !ARGV[0]
  puts "Usage: fml2kml.rb fmlfile designindex > <walls collada>"
else
  dae = Collada::Document.from_fml(ARGV[0])
  puts dae.values[ARGV[1].to_i || 0]
end
