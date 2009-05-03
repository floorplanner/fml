#!/usr/bin/env ruby
require 'lib/kml'

KML::Archive.new("test.kmz") do |kmz|
  kml = KML::Document.new
  mark =   KML::Entity::Placemark.new('Floor plan')
  model =  KML::Entity::Model.new("ah_345")
  model << KML::Entity::Location.new(55.3435,46.456456,0.0)
  mark << model
  kml  << mark

  kmz.add_document(kml)
end
