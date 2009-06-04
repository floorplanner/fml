require 'lib/geom'
require 'lib/geom/glu_tess'

v = [
  [ 2, 1, 0],[-2, 1, 0],
  [-2,-1, 0],[ 2,-1, 0]
].map! {|f| Geom::Vertex.new(f[0],f[1],f[2])}

p = Geom::Polygon.new(v)
p.tess = Geom::GluTesselator
p.update

puts p.faces.length
