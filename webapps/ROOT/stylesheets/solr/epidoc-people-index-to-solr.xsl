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
      <xsl:for-each-group select="//tei:persName[ancestor::tei:div/@type='edition'][@ref!='']" group-by="lower-case(translate(replace(@ref, ' #', '; '), '#', ''))">
        <xsl:variable name="pers-id" select="translate(replace(@ref, ' #', '; '), '#', '')"/>
        <xsl:variable name="person-id" select="document(concat('file:',system-property('user.dir'),'/webapps/ROOT/content/fiscus_framework/resources/people.xml'))//tei:person[descendant::tei:idno=$pers-id][descendant::tei:persName!=''][1]"/>
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
              <xsl:when test="$person-id"><xsl:value-of select="$person-id/tei:persName[1]" />
                <xsl:if test="$person-id/tei:persName[2]/text()"><xsl:text> [</xsl:text><xsl:value-of select="$person-id/tei:persName[2]" /><xsl:text>]</xsl:text></xsl:if></xsl:when>
              <xsl:when test="$pers-id and not($person-id)"><xsl:value-of select="$pers-id" /></xsl:when>
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
              <xsl:when test="$person-id"><xsl:value-of select="concat('../../texts/people.html#', substring-after(translate($person-id/tei:idno, '#', ''), 'people/'))" /></xsl:when>
              <xsl:otherwise><xsl:text>~</xsl:text></xsl:otherwise>
            </xsl:choose>
          </field>
          <!--<field name="index_base_form">
            <xsl:value-of select="." />
          </field>-->
          <!--<field name="index_keys">
            <xsl:value-of select="lower-case(translate(replace(@key, ' #', '; '), '#', ''))" />
          </field>-->
          <xsl:apply-templates select="current-group()" />
        </doc>
      </xsl:for-each-group>
      
      <xsl:for-each-group select="//tei:persName[ancestor::tei:div/@type='edition'][not(@ref) or @ref=''][not(descendant::tei:name[@ref!=''])][not(ancestor::tei:name[@ref!=''])]" group-by="lower-case(.)">
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
      
      <xsl:for-each-group select="//tei:persName[ancestor::tei:div/@type='edition'][not(@ref) or @ref=''][descendant::tei:name[@ref!='']]" group-by="lower-case(tei:name[1]/@ref)">
        <doc>
          <field name="document_type">
            <xsl:value-of select="$subdirectory" />
            <xsl:text>_</xsl:text>
            <xsl:value-of select="$index_type" />
            <xsl:text>_index</xsl:text>
          </field>
          <xsl:call-template name="field_file_path" />
          <field name="index_item_name">
            <xsl:text># </xsl:text>
            <xsl:choose>
              <xsl:when test="starts-with(normalize-space(tei:name[1]/@ref), '\s')"><xsl:value-of select="substring(normalize-space(tei:name[1]/@ref), 2)"/></xsl:when>
              <xsl:otherwise><xsl:value-of select="normalize-space(tei:name[1]/@ref)"/></xsl:otherwise>
            </xsl:choose>
          </field>
          <field name="index_external_resource">
            <xsl:text>~</xsl:text>
          </field>
          <xsl:apply-templates select="current-group()" />
        </doc>
      </xsl:for-each-group>
      
      <xsl:for-each-group select="//tei:persName[ancestor::tei:div/@type='edition'][not(@ref) or @ref=''][ancestor::tei:name[@ref!='']]" group-by="lower-case(tei:name[1]/@ref)">
        <doc>
          <field name="document_type">
            <xsl:value-of select="$subdirectory" />
            <xsl:text>_</xsl:text>
            <xsl:value-of select="$index_type" />
            <xsl:text>_index</xsl:text>
          </field>
          <xsl:call-template name="field_file_path" />
          <field name="index_item_name">
            <xsl:text># </xsl:text>
            <xsl:choose>
              <xsl:when test="starts-with(normalize-space(ancestor::tei:name[1]/@ref), '\s')"><xsl:value-of select="substring(normalize-space(ancestor::tei:name[1]/@ref), 2)"/></xsl:when>
              <xsl:otherwise><xsl:value-of select="normalize-space(ancestor::tei:name[1]/@ref)"/></xsl:otherwise>
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
  

  <xsl:template match="tei:persName">
    <xsl:call-template name="field_index_instance_location" />
  </xsl:template>

</xsl:stylesheet>
