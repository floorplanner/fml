#!/usr/bin/env ruby
$: << File.join(File.dirname(__FILE__), "/../lib" )
require 'floorplanner'

if ARGV.length < 2
  puts "\n  Usage: fml2dae.rb [-xrefs] path/to/fml out.dae"
else
  xrefs = false
  if ARGV[0] == "-xrefs"
    ARGV.shift
    xrefs = true
  end
  doc = Floorplanner::DesignDocument.new(ARGV[0])
  doc.to_dae(ARGV[1],:xrefs => xrefs, :ceiling => false)
end
