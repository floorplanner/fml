<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template match="/">
    <COLLADA xmlns="http://www.collada.org/2005/11/COLLADASchema" version="1.4.1">
      <asset>
        <contributor>
          <authoring_tool>FML2KML | Floorplanner.com</authoring_tool>
        </contributor>
        <unit name="meters" meter="1.0"/>
        <up_axis>Z_UP</up_axis>
      </asset>
      <library_materials>
        <material id="wall" name="wall">
          <instance_effect url="#wall-effect"/>
        </material>
      </library_materials>
      <library_effects>
        <effect id="wall-effect" name="wall-effect">
          <profile_COMMON>
            <technique sid="COMMON">
              <lambert>
                <emission>
                  <color>0.000000 0.000000 0.000000 1</color>
                </emission>
                <ambient>
                  <color>0.000000 0.000000 0.000000 1</color>
                </ambient>
                <diffuse>
                  <color>0.847059 0.847059 0.847059 1</color>
                </diffuse>
                <transparent>
                  <color>1 1 1 1</color>
                </transparent>
                <transparency>
                  <float>0.000000</float>
                </transparency>
              </lambert>
            </technique>
          </profile_COMMON>
        </effect>
      </library_effects>
      <xsl:for-each select="project/floors/floor/designs/design">
        <library_geometries>
          <xsl:variable name="dID">design_<xsl:value-of select="id"/></xsl:variable>
          <xsl:attribute name="id">
            <xsl:value-of select="$dID"/>
          </xsl:attribute>
          <xsl:for-each select="lines/line">
            <xsl:variable name="wID"><xsl:value-of select="$dID"/>_wall_<xsl:value-of select="position()"/></xsl:variable>
            <geometry>
              <xsl:attribute name="id">
                <xsl:value-of select="$wID"/>
              </xsl:attribute>
              <mesh>
                <source name="position">
                  <xsl:attribute name="id"><xsl:value-of select="$wID"/>_pos</xsl:attribute>
                  <float_array count="24">
                    <xsl:attribute name="id"><xsl:value-of select="$wID"/>_pos_a</xsl:attribute>
                    <xsl:value-of select="points"/>|<xsl:value-of select="thickness"/>|<xsl:value-of select="height"/>
                  </float_array>
                  <technique_common>
                    <accessor count="8" offset="0" stride="3">
                      <xsl:attribute name="source">#<xsl:value-of select="$wID"/>_pos_a</xsl:attribute>
                      <param name="X" type="float"></param>
                      <param name="Y" type="float"></param>
                      <param name="Z" type="float"></param>
                    </accessor>
                  </technique_common>
                </source>
                <source name="normal">
                  <xsl:attribute name="id"><xsl:value-of select="$wID"/>_nor</xsl:attribute>
                  <float_array count="72">
                    <xsl:attribute name="id"><xsl:value-of select="$wID"/>_nor_a</xsl:attribute>
                    0 0 1 0 0 1 0 0 1 0 0 1 0 1 0 0 1 0 0 1 0 0 1 0 0 -1 0 0 -1 0 0 -1 0 0 -1 0 -1 0 0 -1 0 0 -1 0 0 -1 0 0 1 0 0 1 0 0 1 0 0 1 0 0 0 0 -1 0 0 -1 0 0 -1 0 0 -1
                  </float_array>
                  <technique_common>
                    <accessor count="24" offset="0" stride="3">
                    <xsl:attribute name="source">#<xsl:value-of select="$wID"/>_nor_a</xsl:attribute>
                        <param name="X" type="float"></param>
                        <param name="Y" type="float"></param>
                        <param name="Z" type="float"></param>
                    </accessor>
                  </technique_common>
                </source>
                <vertices>
                  <xsl:attribute name="id"><xsl:value-of select="$wID"/>_ver</xsl:attribute>
                  <input semantic="POSITION">
                    <xsl:attribute name="source">#<xsl:value-of select="$wID"/>_pos</xsl:attribute>
                  </input>
                </vertices>
                <polylist count="6" material="wall">
                  <input offset="0" semantic="VERTEX">
                    <xsl:attribute name="source">#<xsl:value-of select="$wID"/>_ver</xsl:attribute>
                  </input>
                  <input offset="1" semantic="NORMAL">
                    <xsl:attribute name="source">#<xsl:value-of select="$wID"/>_nor</xsl:attribute>
                  </input>
                  <vcount>4 4 4 4 4 4</vcount>
                  <p>0 0 2 1 3 2 1 3 0 4 1 5 5 6 4 7 6 8 7 9 3 10 2 11 0 12 4 13 6 14 2 15 3 16 7 17 5 18 1 19 5 20 7 21 6 22 4 23</p>
                </polylist>
              </mesh>
            </geometry>
          </xsl:for-each>
        </library_geometries>
      </xsl:for-each>
      <library_visual_scenes>
        <xsl:for-each select="project/floors/floor/designs/design">
          <xsl:variable name="dID">design_<xsl:value-of select="id"/></xsl:variable>
          <visual_scene>
            <xsl:attribute name="id"><xsl:value-of select="$dID"/>_scene</xsl:attribute>
            <xsl:attribute name="name">
              <xsl:value-of select="name"/>
            </xsl:attribute>
            <xsl:for-each select="lines/line">
              <xsl:variable name="wID"><xsl:value-of select="$dID"/>_wall_<xsl:value-of select="position()"/></xsl:variable>
              <node>
                <xsl:attribute name="id"><xsl:value-of select="$wID"/>_node</xsl:attribute>
                <rotate sid="rotateZ">0 0 1 0</rotate>
                <rotate sid="rotateY">0 1 0 0</rotate>
                <rotate sid="rotateX">1 0 0 0</rotate>
                <instance_geometry>
                  <xsl:attribute name="url">#<xsl:value-of select="$wID"/></xsl:attribute>
                  <bind_material>
                    <technique_common>
                      <instance_material symbol="wall" target="#wall"/>
                    </technique_common>
                  </bind_material>
                </instance_geometry>
              </node>
            </xsl:for-each>
          </visual_scene>
        </xsl:for-each>
      </library_visual_scenes>
      <scene>
        <instance_visual_scene url="#VisualSceneNode"/>
      </scene>
    </COLLADA>
  </xsl:template>
</xsl:stylesheet>
