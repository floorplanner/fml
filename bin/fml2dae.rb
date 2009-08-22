#!/usr/bin/env ruby
$: << File.join(File.dirname(__FILE__), "/../lib" )
require 'floorplanner'

if ARGV.length < 2
  puts "\n  Usage: fml2dae.rb [-xrefs] design_id|design_name path/to/fml out.dae" 
else
  xrefs = false
  if ARGV[0] == "-xrefs"
    ARGV.shift
    xrefs = true
  end
  doc = Floorplanner::Document.new(ARGV[1])
  doc.to_dae(ARGV[0],ARGV[2],xrefs)
end
