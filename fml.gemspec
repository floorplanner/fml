# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name    = "fml"
  s.version = "0.2.4"
  s.date    = "2010-11-25"
  
  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.0") if s.respond_to? :required_rubygems_version=
  
  s.authors = ["Dusan Maliarik"]
  s.description = %q{Floor plan document toolkit}
  s.email = %q{dusan.maliarik@gmail.com}
  s.executables = ["fml2dae.rb"]
  s.files = %w(.gitignore README Rakefile TODO bin/fml2dae.rb fml.gemspec lib/collada/document.rb lib/collada/geometry.rb lib/config.yml lib/floorplanner.rb lib/floorplanner/area_builder.rb lib/floorplanner/asset.rb lib/floorplanner/collada_export.rb lib/floorplanner/design.rb lib/floorplanner/document.rb lib/floorplanner/opening3d.rb lib/floorplanner/svg_export.rb lib/floorplanner/wall3d.rb lib/floorplanner/wall_builder.rb lib/floorplanner/xml.rb lib/geom.rb lib/geom/connection.rb lib/geom/ear_trim.rb lib/geom/edge.rb lib/geom/glu_tess.rb lib/geom/intersection.rb lib/geom/matrix3d.rb lib/geom/number.rb lib/geom/plane.rb lib/geom/polygon.rb lib/geom/triangle.rb lib/geom/triangle_mesh.rb lib/geom/vertex.rb lib/keyhole/archive.rb tasks/github-gem.rake views/design.dae.erb views/design.svg.erb xml/collada_schema_1_4.xsd xml/fml.rng xml/fml2kml.xsl)
  s.homepage = %q{http://floorplanner.com/}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Floorplanner.com FML document toolkit}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<nokogiri>)
      s.add_runtime_dependency(%q<rubyzip>)
      s.add_runtime_dependency(%q<roxml>)
    else
      s.add_dependency(%q<nokogiri>)
      s.add_dependency(%q<rubyzip>)
      s.add_dependency(%q<roxml>)
    end
  else
    s.add_dependency(%q<nokogiri>)
    s.add_dependency(%q<rubyzip>)
    s.add_dependency(%q<roxml>)
  end
end

