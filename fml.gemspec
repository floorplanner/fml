# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name    = "fml"
  s.version = "0.2.2"
  s.date    = "2009-09-23"
  
  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.0") if s.respond_to? :required_rubygems_version=
  
  s.authors = ["Dusan Maliarik"]
  s.description = %q{Floor plan document toolkit}
  s.email = %q{dusan.maliarik@gmail.com}
  s.executables = ["fml2dae.rb","fml2obj.rb"]
  s.files = %w(lib/keyhole/archive.rb lib/geom/plane.rb lib/floorplanner/area_builder.rb bin/fml2dae.rb .gitignore xml/fml2kml.xsl xml/collada_schema_1_4.xsd lib/geom/number.rb lib/geom/connection.rb lib/floorplanner/design.rb lib/floorplanner/collada_export.rb lib/geom/polygon.rb lib/geom.rb lib/floorplanner/asset.rb xml/fml.rng views/design.rib.erb lib/geom/matrix3d.rb lib/geom/ear_trim.rb lib/floorplanner/obj_export.rb lib/floorplanner.rb README views/design.obj.erb views/design.dae.erb lib/config.yml lib/geom/intersection.rb lib/floorplanner/svg_export.rb lib/floorplanner/rib_export.rb fml.gemspec Rakefile tasks/github-gem.rake lib/geom/triangle.rb lib/geom/edge.rb bin/fml2obj.rb lib/geom/triangle_mesh.rb lib/floorplanner/wall_builder.rb lib/floorplanner/wall3d.rb lib/floorplanner/document.rb lib/floorplanner/opening3d.rb lib/collada/geometry.rb views/design.svg.erb lib/geom/vertex.rb lib/geom/glu_tess.rb lib/collada/document.rb)
  s.homepage = %q{http://floorplanner.com/}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Floorplanner.com FML document toolkit}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<libxml-ruby>)
      s.add_runtime_dependency(%q<rubyzip>)
    else
      s.add_dependency(%q<libxml-ruby>)
      s.add_dependency(%q<rubyzip>)
    end
  else
    s.add_dependency(%q<libxml-ruby>)
    s.add_dependency(%q<rubyzip>)
  end
end

