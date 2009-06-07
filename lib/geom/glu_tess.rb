require 'opengl'

module Geom
  class GluTesselator
    include Gl,Glu,Glut
    def self.triangulate(poly)
      result = Array.new

      t = gluNewTess
      gluTessCallback(t,GLU_TESS_VERTEX,method(:vertex_callback).to_proc)
      gluTessCallback(t,GLU_TESS_BEGIN,method(:begin_callback).to_proc)
      gluTessCallback(t,GLU_TESS_EDGE_FLAG,proc{})
      gluTessBeginPolygon(t,self)
      gluTessBeginContour(t)

      poly.vertices.each_with_index do |v,i|
        gluTessVertex(t,[v.x,v.y,v.z],v)
      end

      gluTessEndContour(t)
      gluTessEndPolygon(t)
    end

    private

    def self.vertex_callback(v)
      puts v
    end

    def self.begin_callback(a)
      puts "begin"
    end
  end
end
