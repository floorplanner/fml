module Geom
  class Matrix3D < Matrix
    def self.rotation_matrix(x,y,z,rad)
      n_cos = Math.cos(rad)
      n_sin = Math.sin(rad)
      s_cos = 1 - n_cos

      sxy = x * y * s_cos
      syz = y * z * s_cos
      sxz = x * z * s_cos

      sz  = n_sin * z
      sy  = n_sin * y
      sx  = n_sin * x

      n11  = n_cos + x * x * s_cos
      n12  = -sz + sxy
      n13  = sy + sxz
      n14  = 0

      n21  = sz + sxy
      n22  = n_cos + y * y * s_cos
      n23  = -sx + syz
      n24  = 0

      n31  = -sy + sxz
      n32  = sx + syz
      n33  = n_cos + z * z * s_cos
      n34  = 0

      self[
        [n11,n12,n13,n14],
        [n21,n22,n23,n24],
        [n31,n32,n33,n34],
        [0,0,0,1]
      ]
    end

    def self.rotationX(rad)
      c = Math.cos(rad)
      s = Math.sin(rad)

      self[
        [1,0, 0,0],
        [0,c,-s,0],
        [0,s, c,0],
        [0,0, 0,1],
      ]
    end

    def self.rotationZ(rad)
      c  = Math.cos(rad)
      s  = Math.sin(rad)

      self[
        [c,-s,0,0],
        [s, c,0,0],
        [0, 0,1,0],
        [0, 0,0,1]
      ]
    end

    def self.translation(x,y,z)
      self[
        [1,0,0,x],
        [0,1,0,y],
        [0,0,1,z],
        [0,0,0,1]
      ]
    end

    def self.multiply_vector_3x3(m,v)
      ma = m.to_a
      vx = v.x
      vy = v.y
      vz = v.z

      v.x = vx * ma[0][0] + vy * ma[0][1] + vz * ma[0][2]
      v.y = vx * ma[1][0] + vy * ma[1][1] + vz * ma[1][2]
      v.z = vx * ma[2][0] + vy * ma[2][1] + vz * ma[2][2]
    end
  end
end
