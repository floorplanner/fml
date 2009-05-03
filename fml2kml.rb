#!/usr/bin/env ruby
require 'lib/kml'

KML::Archive.new("test.kmz") do |kmz|
  kml   =  KML::Document.new
  mark  =  KML::Entity::Placemark.new('Floor plan','Joe',nil,"http://floorplanner.com")
  mark  << KML::Entity::Point.new(14.420929,50.090631)
  kml   << mark

  kmz.add_document(kml)
end
