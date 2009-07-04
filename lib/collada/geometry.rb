if Geom && Geom::TriangleMesh

  module Geom
    class TriangleMesh

      GEOMETRY_QUERY      = '/COLLADA/library_geometries/geometry[@id="%s"]'
      NODE_QUERY          = '/COLLADA/library_nodes//node[@id="%s"]'
      VISUAL_SCENE_QUERY  = '/COLLADA/library_visual_scenes/visual_scene[@id="%s"]'
      SCENE_QUERY         = '/COLLADA/scene/instance_visual_scene'

      attr_accessor :xml
      
      def self.collada(xml)
        @@cache ||= {}
        result = TriangleMesh.new
        result.xml = xml

        scene_id = xml.find(SCENE_QUERY).first.attributes['url'][1..-1]
        scene = xml.find(VISUAL_SCENE_QUERY % scene_id).first
        scene.children.each do |child|
          result.eval_node(child) if child.name == "node"
        end

        result
      end

      def eval_node(node,parent=nil)
        parent = node.parent unless parent
        parent_matrix = Matrix3D.identity
        if parent.name == "node"
          if @@cache.include?(parent)
            parent_matrix = @@cache[parent]
          else
            parent_matrix = get_node_matrix(parent)
            @@cache[parent] = parent_matrix
          end
        end
        node_matrix = get_node_matrix(node).multiply(parent_matrix)
        node.children.each do |child|
          case child.name
          when "node"
            eval_node(child)
          when "instance_geometry"
            load_geometry(child.attributes['url'][1..-1],node_matrix)
          when "instance_node"
            eval_node(expand_node(child),node)
          end
        end
      end

      private

      def load_geometry(gid,matrix=nil)
        matrix = Matrix3D.identity unless matrix
        geometry = @xml.find(GEOMETRY_QUERY % gid).first
        mesh = TriangleMesh.new

        floats = Array.new
        geometry.find('mesh/triangles').each do |triangles|
          vertices_id = triangles.find('input[@semantic="VERTEX"]').first.attributes['source'][1..-1]
          source_id   = geometry.find('mesh/vertices[@id="%s"]/input[@semantic="POSITION"]' % vertices_id).first.attributes['source'][1..-1]

          floats.concat geometry.find('mesh/source[@id="%s"]/float_array' % source_id).first.get_floats
        end

        (floats.length/3).times do |i|
          offset = i*3
          mesh.vertices.push Vertex.new(floats[offset],floats[offset+1],floats[offset+2])
        end

        mesh.transform_vertices(matrix)
        @meshes << mesh
      end

      def expand_node(instance)
        parent = instance.parent
        node_id = instance.attributes['url'][1..-1]
        node = @xml.find(NODE_QUERY % node_id).first.copy(true)

        node
      end

      def get_node_matrix(node)
        result = Matrix3D.identity
        node.children.each do |child|
          case child.name
          when "translate"
            f = child.get_floats
            t = Matrix3D.translation(f[0],f[1],f[2])
            result = t.multiply(result)
          when "scale"
            f = child.get_floats
            t = Matrix3D.scale(f[0],f[1],f[2])
            result = t.multiply(result)
          when "rotate"
            f = child.get_floats
            t = Matrix3D.rotation_matrix(f[0],f[1],f[2],f[3])
            result = t.multiply(result)
          when "matrix"
            f = child.get_floats
            t = Matrix3D[
              [ f[0], f[1], f[2], f[3]],
              [ f[4], f[5], f[6], f[7]],
              [ f[8], f[9],f[10],f[11]],
              [f[12],f[13],f[14],f[15]]
            ]
            result = t.multiply(result)
          end
        end
        result
      end

    end
  end

end
