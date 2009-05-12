#!/usr/bin/env ruby
require 'lib/floorplanner'

if !ARGV[0]
  puts "Usage: ?"
else
  fml = Floorplanner::Document.new(ARGV[0])
  puts fml.to_dae
end
