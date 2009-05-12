#!/usr/bin/env ruby
require 'lib/floorplanner'

if ARGV.length == 0
  puts "Usage: ?"
else
  if ARGV[0] != "-design"
    fml = Floorplanner::Document.new(ARGV[0])
    puts fml.to_dae
  else
    fml = XML::Document.file(ARGV[1])
    walls = Floorplanner::Design.new(fml)
    walls.update
    puts walls.to_dae
  end
end
