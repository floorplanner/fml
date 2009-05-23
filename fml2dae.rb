#!/usr/bin/env ruby
require 'lib/floorplanner'

if ARGV.length == 0
  puts "Usage: ?"
else
  if ARGV[0] != "-design"
    fml = Floorplanner::Document.new(ARGV[0])
    puts fml.to_dae
  else
    fml = XML::Document.file(ARGV[2])
    design = Floorplanner::Design.new(fml,ARGV[1])
    puts design.to_obj
  end
end
