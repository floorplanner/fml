module Collada
  class Geometry < Geom::TriangleMesh

    SCENE_QUERY        = '/COLLADA/scene/instance_visual_scene'
    VISUAL_SCENE_QUERY = '/COLLADA/library_visual_scenes/visual_scene[@id="%s"]'
    GEOMETRY_QUERY     = '/COLLADA/library_geometries/geometry[@id="%s"]'
    NODE_QUERY         = '/COLLADA/library_nodes//node[@id="%s"]'

    def self.doc doc
      result = Geometry.new
      result.instance_eval do
        @doc   = doc
        @cache = {}

        scene_id = @doc.xpath(SCENE_QUERY).first.attribute('url').value[1..-1]
        scene = @doc.xpath(VISUAL_SCENE_QUERY % scene_id).first
        scene.children.each do |child|
          eval_node(child) if child.name == "node"
        end
      end
      result
    end

    private

    def eval_node node, parent=nil
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
          load_geometry(child.attribute('url').value[1..-1],node_matrix)
        when "instance_node"
          eval_node(expand_node(child),node)
        end
      end
    end

    def load_geometry gid, matrix=nil
      geometry = @doc.xpath(GEOMETRY_QUERY % gid).first
      mesh = Geom::TriangleMesh.new

      floats = Array.new
      geometry.xpath('mesh/triangles').each do |triangles|
        vertices_id = triangles.xpath('input[@semantic="VERTEX"]').first.attribute('source').value[1..-1]
        source_id   = geometry.xpath('mesh/vertices[@id="%s"]/input[@semantic="POSITION"]' % vertices_id).first.attribute('source').value[1..-1]
        floats.concat geometry.xpath('mesh/source[@id="%s"]/float_array' % source_id).first.content.split.map(&:to_f)
      end

      (floats.length/3).times do |i|
        offset = i*3
        mesh.vertices.push Geom::Vertex.new(floats[offset],floats[offset+1],floats[offset+2])
      end

      mesh.transform_vertices(matrix) if matrix
      @meshes << mesh
    end

    def expand_node instance
      node_id = instance.attribute('url').value[1..-1]
      @doc.xpath(NODE_QUERY % node_id).first
    end

    def get_node_matrix node, source=nil
      result = source ? source : Geom::Matrix3D.identity
      node.children.each do |child|
        case child.name
        when "translate"
          f = child.get_floats
          t = Geom::Matrix3D.translation(f[0],f[1],f[2])
          result *= t
        when "scale"
          f = child.get_floats
          t = Geom::Matrix3D.scale(f[0],f[1],f[2])
          result *= t
        when "rotate"
          f = child.get_floats
          t = Geom::Matrix3D.rotation(f[0],f[1],f[2],f[3])
          result *= t
        when "matrix"
          f = child.content.split.map(&:to_f)
          t = Geom::Matrix3D[
            [ *f[0..3]   ],
            [ *f[4..7]   ],
            [ *f[8..11]  ],
            [ *f[12..15] ]
          ]
          result *= t
        end
      end
      result
    end

  end
end
