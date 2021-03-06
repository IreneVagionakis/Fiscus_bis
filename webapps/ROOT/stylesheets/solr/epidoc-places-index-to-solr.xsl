<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all"
                version="2.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- This XSLT transforms a set of EpiDoc documents into a Solr
       index document representing an index of symbols in those
       documents. -->

  <xsl:import href="epidoc-index-utils.xsl" />

  <xsl:param name="index_type" />
  <xsl:param name="subdirectory" />

  <xsl:template match="/">
    <add>
      <xsl:for-each-group select="//tei:placeName[ancestor::tei:div/@type='edition'][@ref!='']" group-by="lower-case(translate(replace(@ref, ' #', '; '), '#', ''))">
        <xsl:variable name="pl-id" select="translate(replace(@ref, ' #', '; '), '#', '')"/>
        <xsl:variable name="place-id" select="document(concat('file:',system-property('user.dir'),'/webapps/ROOT/content/fiscus_framework/resources/places.xml'))//tei:place[descendant::tei:idno=$pl-id][descendant::tei:placeName!=''][1]"/>
        <doc>
          <field name="document_type">
            <xsl:value-of select="$subdirectory" />
            <xsl:text>_</xsl:text>
            <xsl:value-of select="$index_type" />
            <xsl:text>_index</xsl:text>
          </field>
          <xsl:call-template name="field_file_path" />
          <field name="index_item_name">
            <xsl:choose>
              <xsl:when test="$place-id/tei:placeName"><xsl:value-of select="$place-id/tei:placeName[1]" /> 
                <xsl:if test="$place-id/tei:placeName[2]/text()"><xsl:text> [</xsl:text><xsl:value-of select="$place-id/tei:placeName[2]" /><xsl:text>]</xsl:text></xsl:if>
              </xsl:when>
              <xsl:when test="$pl-id and not($place-id)"><xsl:value-of select="$pl-id" /></xsl:when>
              <xsl:otherwise>
                <xsl:text>~ </xsl:text>
                <xsl:choose>
                  <xsl:when test="starts-with(normalize-space(.), '\s')"><xsl:value-of select="substring(normalize-space(.), 2)"/></xsl:when>
                  <xsl:otherwise><xsl:value-of select="normalize-space(.)"/></xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </field>
          <field name="index_external_resource">
            <xsl:choose>
              <xsl:when test="$place-id"><xsl:value-of select="concat('../../texts/places.html#', substring-after(translate($place-id/tei:idno, '#', ''), 'places/'))" /></xsl:when>
              <xsl:otherwise><xsl:text>~</xsl:text></xsl:otherwise>
            </xsl:choose>
          </field>
          <!--<field name="index_base_form">
            <xsl:value-of select="."/>
          </field>-->
          <!--<field name="index_keys">
            <xsl:value-of select="lower-case(translate(replace(@key, ' #', '; '), '#', ''))" />
          </field>-->
          <xsl:apply-templates select="current-group()" />
        </doc>
      </xsl:for-each-group>
    
      <xsl:for-each-group select="//tei:placeName[ancestor::tei:div/@type='edition'][not(@ref) or @ref='']" group-by="lower-case(.)">
        <doc>
          <field name="document_type">
            <xsl:value-of select="$subdirectory" />
            <xsl:text>_</xsl:text>
            <xsl:value-of select="$index_type" />
            <xsl:text>_index</xsl:text>
          </field>
          <xsl:call-template name="field_file_path" />
          <field name="index_item_name">
                <xsl:text>~ </xsl:text>
                <xsl:choose>
                  <xsl:when test="starts-with(normalize-space(.), '\s')"><xsl:value-of select="substring(normalize-space(.), 2)"/></xsl:when>
                  <xsl:otherwise><xsl:value-of select="normalize-space(.)"/></xsl:otherwise>
                </xsl:choose>
          </field>
          <field name="index_external_resource">
            <xsl:text>~</xsl:text>
          </field>
          <xsl:apply-templates select="current-group()" />
        </doc>
      </xsl:for-each-group>
    </add>
  </xsl:template>

  <xsl:template match="tei:placeName">
    <xsl:call-template name="field_index_instance_location" />
  </xsl:template>

</xsl:stylesheet>
