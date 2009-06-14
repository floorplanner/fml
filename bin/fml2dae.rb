#!/usr/bin/env ruby
$: << File.join(File.dirname(__FILE__), "/../lib" )
require 'floorplanner'

if ARGV.length < 2
  puts "\n  Usage: fml2dae.rb design_id path/to/fml" 
else
  doc = Floorplanner::Document.new(ARGV[1])
  doc.to_dae(ARGV[0],ARGV[2])
end
