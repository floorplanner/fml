require 'opengl'

module Geom
  class DisplayGL
    include Gl,Glu,Glut
    def initialize(mesh,win_title=nil)
      @mesh = mesh
      @win_width = @win_height = 500
      @win_title = win_title || self.class.to_s
    end

    def display
      glutInit
      glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH)
      glutInitWindowSize(@win_width, @win_height)
      glutCreateWindow(@win_title)

      glutDisplayFunc(method(:display_callback).to_proc)
      glutKeyboardFunc(method(:keyboard_callback).to_proc)
      glutMouseFunc(method(:mouse_callback).to_proc)

      scene
      glutMainLoop
    end

    def display_callback
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
      draw_mesh
      glutSwapBuffers
    end

    def keyboard_callback(key,x,y)
      case (key)
      when ?\e
        exit(0)
      end
    end

    def mouse_callback(button,released,x,y)
      rx = (x - @win_width/2.0)  / 10
      ry = (y - @win_height/2.0) / 10
      gluLookAt(rx,ry,0.0, 0.0, 0.0, 0.0, 0.0, rx, 0.0)
      glutPostRedisplay
      puts rx,ry
    end

    def draw_mesh
      glBegin(GL_QUADS)
      @mesh.faces.each do |t|
        t.vertices.each do |v|
          glVertex([v.x,v.y,v.z])
        end
      end
      glEnd
    end

    def scene
      light_diffuse  = [1.0, 0.0, 0.0, 1.0]
      light_position = [1.0, 1.0, 1.0, 0.0]

      glLight(GL_LIGHT0, GL_DIFFUSE, light_diffuse)
      glLight(GL_LIGHT0, GL_POSITION, light_position)
      glEnable(GL_LIGHT0)
      glEnable(GL_LIGHTING)
      
      glEnable(GL_DEPTH_TEST)
      
      glMatrixMode(GL_PROJECTION)
      gluPerspective(40.0, 1.0, 1.0,  10.0)
      glMatrixMode(GL_MODELVIEW)
      gluLookAt(0.0, 0.0, 15.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0)
      
      glTranslate(0.0, 0.0, -1.0)
      glRotate(60, 1.0, 0.0, 0.0)
      glRotate(-20, 0.0, 0.0, 1.0)
    end
  end
end
