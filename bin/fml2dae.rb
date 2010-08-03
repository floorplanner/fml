#!/usr/bin/env ruby
$: << File.join(File.dirname(__FILE__), "/../lib" )
require 'floorplanner'

if ARGV.length < 2
  puts "\n  Usage: fml2dae.rb [-xrefs] path/to/fml out.dae"
  exit
end

conf = {
  :ceiling      => false,
  :window_glass => false
}

if ARGV[0] == "-xrefs"
  ARGV.shift
  conf[:xrefs] = true
end
doc = Floorplanner::XML::Document.from_xml(open(ARGV[0]))
doc.to_dae(ARGV[1], conf)
