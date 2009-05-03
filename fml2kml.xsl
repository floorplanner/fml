<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template match="/">
    <kml xmlns="http://www.opengis.net/kml/2.2">
      <Folder>
        <name><xsl:value-of select="/project/name"/></name>
        <xsl:for-each select="/project/floors/floor">
          <Folder>
            <name><xsl:value-of select="name"/></name>
            <xsl:if test="position() &gt; 1">
              <visibility>0</visibility>
            </xsl:if>
            <xsl:apply-templates select="designs/design"/>
          </Folder>
        </xsl:for-each>
      </Folder>
    </kml>
  </xsl:template>

  <xsl:template match="design">
    <Placemark>
      <name><xsl:value-of select="name"/></name>
      <xsl:if test="position() &gt; 1">
        <visibility>0</visibility>
      </xsl:if>
      <xsl:for-each select="objects/object">
        <Model>
          <altitudeMode>relativeToGround</altitudeMode>
          <Location>
            <longitude><xsl:value-of select="points"/></longitude>
            <latitude><xsl:value-of select="points"/></latitude>
            <altitude><xsl:value-of select="points"/></altitude>
          </Location>
          <Orientation>
            <heading><xsl:value-of select="rotation"/></heading>
            <tilt><xsl:value-of select="rotation"/></tilt>
            <roll><xsl:value-of select="rotation"/></roll>
          </Orientation>
          <Scale>
            <x><xsl:value-of select="size"/></x>
            <y><xsl:value-of select="size"/></y>
            <z><xsl:value-of select="size"/></z>
          </Scale>
          <xsl:for-each select="asset">
            <Link>
              <href>
                <xsl:variable name="refid" select="@refid"/>
                <xsl:choose>
                  <xsl:when test="../../../assets/asset[@id=$refid]/url3d">
                    <xsl:value-of select="../../../assets/asset[@id=$refid]/url3d"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="../../../assets/asset[@id=$refid]/url2d"/>
                  </xsl:otherwise>
                </xsl:choose>
              </href>
            </Link>
          </xsl:for-each>
        </Model>
      </xsl:for-each>
    </Placemark>
  </xsl:template>

</xsl:stylesheet>
