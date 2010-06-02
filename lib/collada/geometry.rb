module Collada
  class Geometry < Geom::TriangleMesh

    SCENE_QUERY        = '/COLLADA/scene/instance_visual_scene'
    VISUAL_SCENE_QUERY = '/COLLADA/library_visual_scenes/visual_scene[@id="%s"]'
    GEOMETRY_QUERY     = '/COLLADA/library_geometries/geometry[@id="%s"]'
    NODE_QUERY         = '/COLLADA/library_nodes//node[@id="%s"]'

    def self.doc(xml)
      result = Geometry.new
      result.instance_eval do
        @xml   = xml
        @cache = {}

        scene_id = xml.find(SCENE_QUERY).first.attributes['url'][1..-1]
        scene = xml.find(VISUAL_SCENE_QUERY % scene_id).first
        scene.children.each do |child|
          eval_node(child) if child.name == "node"
        end
      end
      result
    end

    private

    def eval_node(node,parent=nil)
      parent = node.parent unless parent
      parent_matrix = Geom::Matrix3D.identity
      if parent.name == "node"
        if @cache.include?(parent)
          parent_matrix = @cache[parent]
        else
          parent_matrix = get_node_matrix(parent)
          @cache[parent] = parent_matrix
        end
      end

      node_matrix  = get_node_matrix(node,parent_matrix)
      @cache[node] = node_matrix

      node.children.each do |child|
        case child.name
        when "node"
          eval_node(child,node)
        when "instance_geometry"
          load_geometry(child.attributes['url'][1..-1],node_matrix)
        when "instance_node"
          eval_node(expand_node(child),node)
        end
      end
    end

    def load_geometry(gid,matrix=nil)
      geometry = @xml.find(GEOMETRY_QUERY % gid).first
      mesh = Geom::TriangleMesh.new

      floats = Array.new
      geometry.find('mesh/triangles').each do |triangles|
        vertices_id = triangles.find('input[@semantic="VERTEX"]').first.attributes['source'][1..-1]
        source_id   = geometry.find('mesh/vertices[@id="%s"]/input[@semantic="POSITION"]' % vertices_id).first.attributes['source'][1..-1]

        floats.concat geometry.find('mesh/source[@id="%s"]/float_array' % source_id).first.get_floats
      end

      (floats.length/3).times do |i|
        offset = i*3
        mesh.vertices.push Geom::Vertex.new(floats[offset],floats[offset+1],floats[offset+2])
      end

      mesh.transform_vertices(matrix) if matrix
      @meshes << mesh
    end

    def expand_node(instance)
      node_id = instance.attributes['url'][1..-1]
      @xml.find(NODE_QUERY % node_id).first
    end

    def get_node_matrix(node,source=nil)
      result = source ? source : Geom::Matrix3D.identity
      node.children.each do |child|
        case child.name
        when "translate"
          f = child.get_floats
          t = Geom::Matrix3D.translation(f[0],f[1],f[2])
          result = result.multiply(t)
        when "scale"
          f = child.get_floats
          t = Geom::Matrix3D.scale(f[0],f[1],f[2])
          result = result.multiply(t)
        when "rotate"
          f = child.get_floats
          t = Geom::Matrix3D.rotation(f[0],f[1],f[2],f[3])
          result = result.multiply(t)
        when "matrix"
          f = child.get_floats
          t = Geom::Matrix3D[
            [ *f[0..3]   ],
            [ *f[4..7]   ],
            [ *f[8..11]  ],
            [ *f[12..15] ]
          ]
          result = result.multiply(t)
        end
      end
      result
    end

  end
end
