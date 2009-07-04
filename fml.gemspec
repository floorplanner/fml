# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{fml}
  s.version = "0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Dusan Maliarik"]
  s.date = %q{2009-06-30}
  s.description = %q{Floor plan document toolkit}
  s.email = %q{dusan.maliarik@gmail.com}
  s.executables = ["fml2dae.rb","fml2obj.rb"]
  s.files = ["README", "bin/fml2dae.rb", "bin/fml2obj.rb", "lib/config.yml",
             "lib/floorplanner.rb", "lib/floorplanner/area_builder.rb", "lib/floorplanner/asset.rb", "lib/floorplanner/collada_export.rb", "lib/floorplanner/design.rb", "lib/floorplanner/document.rb", "lib/floorplanner/obj_export.rb", "lib/floorplanner/opening3d.rb", "lib/floorplanner/rib_export.rb", "lib/floorplanner/svg_export.rb", "lib/floorplanner/wall3d.rb", "lib/floorplanner/wall_builder.rb",
             "lib/geom.rb", "lib/geom/connection.rb", "lib/geom/ear_trim.rb", "lib/geom/edge.rb", "lib/geom/glu_tess.rb", "lib/geom/intersection.rb", "lib/geom/matrix3d.rb", "lib/geom/number3d.rb", "lib/geom/plane.rb", "lib/geom/polygon.rb", "lib/geom/triangle_mesh.rb", "lib/geom/triangle.rb", "lib/geom/vertex.rb",
             "lib/collada/document.rb", "lib/collada/geometry.rb", "lib/keyhole/archive.rb",
             "views/design.dae.erb", "views/design.obj.erb", "views/design.svg.erb", "views/design.rib.erb",
             "xml/fml.rng", "xml/collada_schema_1_4.xsd"
  ]
  s.homepage = %q{http://floorplanner.com/}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Floor plan document toolkit}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<libxml-ruby>)
    else
      s.add_dependency(%q<libxml-ruby>)
    end
  else
    s.add_dependency(%q<libxml-ruby>)
  end
end

