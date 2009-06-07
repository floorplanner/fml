#!/usr/bin/env ruby
$: << File.join(File.dirname(__FILE__), "/../lib" )
require 'floorplanner'

if ARGV.length < 2
  puts "\n  Usage: fml2dae.rb design_id path/to/fml" 
else
  fml = XML::Document.file(ARGV[1])
  design = Floorplanner::Design.new(fml,ARGV[0])
  design.build_geometries
  puts design.to_dae
end
