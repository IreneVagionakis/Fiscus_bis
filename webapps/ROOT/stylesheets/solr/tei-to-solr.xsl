<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:import href="../../kiln/stylesheets/solr/tei-to-solr.xsl" />

  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> Oct 18, 2010</xd:p>
      <xd:p><xd:b>Author:</xd:b> jvieira</xd:p>
      <xd:p>This stylesheet converts a TEI document into a Solr index document. It expects the parameter file-path,
      which is the path of the file being indexed.</xd:p>
    </xd:desc>
  </xd:doc>

  <xsl:template match="/">
    <add>
      <xsl:apply-imports />
    </add>
  </xsl:template>
  
  <xsl:template match="tei:summary/tei:rs[@type='text_type']" mode="facet_ancient_document_type">
    <field name="ancient_document_type">
      <xsl:choose>
        <xsl:when test="text()">
          <xsl:value-of select="translate(translate(., '-', ''), '/', '／')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>-</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </field>
  </xsl:template>
  
  <xsl:template match="tei:msContents/tei:summary/tei:rs[@type='fiscal_property']" mode="facet_fiscal_property">
    <field name="fiscal_property">
      <xsl:choose>
        <xsl:when test="contains(lower-case(.), 'yes')"><xsl:text>Yes</xsl:text></xsl:when>
        <xsl:when test="contains(lower-case(.), 'no')"><xsl:text>No</xsl:text></xsl:when>
        <xsl:when test="contains(lower-case(.), 'uncertain')"><xsl:text>Uncertain</xsl:text></xsl:when>
        <xsl:otherwise><xsl:text>No or uncertain</xsl:text></xsl:otherwise>
      </xsl:choose>
    </field>
  </xsl:template>
  
  <xsl:template match="tei:summary/tei:rs[@type='record_source']" mode="facet_record_source">
    <field name="record_source">
      <xsl:choose>
        <xsl:when test="text()">
          <xsl:value-of select="normalize-space(translate(., '/', '／'))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>-</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </field>
  </xsl:template>
  
  <xsl:template match="tei:msContents/tei:summary/tei:rs[@type='document_tradition']" mode="facet_document_tradition">
    <field name="document_tradition">
      <xsl:choose>
        <xsl:when test="text()">
          <xsl:value-of select="normalize-space(translate(., '/', '／'))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>-</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </field>
  </xsl:template>
  
  <xsl:template match="tei:origDate/tei:note[@type='topical_date']" mode="facet_topical_date">
    <field name="topical_date">
      <xsl:choose>
        <xsl:when test="text()">
          <xsl:value-of select="normalize-space(translate(translate(., '/', '／'), '?', ''))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>-</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </field>
  </xsl:template>
  
  <xsl:template match="tei:origDate/tei:note[@type='redaction_date']" mode="facet_redaction_date">
    <field name="redaction_date">
      <xsl:choose>
        <xsl:when test="text()">
          <xsl:value-of select="normalize-space(translate(translate(., '/', '／'), '?', ''))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>-</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </field>
  </xsl:template>
  
  <xsl:template match="tei:rs[@key!='']" mode="facet_mentioned_keywords_-_terms">
    <xsl:variable name="keyvalue">
      <xsl:choose>
        <xsl:when test="starts-with(@key, ' ')"><xsl:value-of select="substring(normalize-space(@key), 2)"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="normalize-space(@key)"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:for-each select="tokenize($keyvalue, ' #')">
      <xsl:variable name="key" select="translate(., '#', '')"/>
      <xsl:variable name="thesaurus" select="document('../../content/fiscus_framework/resources/thesaurus.xml')//tei:catDesc[lower-case(@n)=lower-case($key)]"/>
      <!-- All keys -->
      <field name="mentioned_keywords_-_terms">
        <xsl:choose>
          <xsl:when test="$thesaurus">
            <xsl:value-of select="translate(translate($thesaurus/@n, '/', '／'), '_', ' ')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="lower-case(translate(translate($key, '_', ' '), '/', '／'))"/>
          </xsl:otherwise>
        </xsl:choose>
    </field>
      <!--<xsl:if test="contains($thesaurus, '*')">
        <!-\- Fifth level -\->
        <field name="mentioned_keywords">
              <xsl:value-of select="concat('5. ', translate(translate($thesaurus/@n, '/', '／'), '_', ' '))" />
        </field>
      </xsl:if>
      <xsl:if test="contains($thesaurus, '▸') or contains($thesaurus, '*')">
      <!-\- Fourth level -\->
      <field name="mentioned_keywords">
        <xsl:choose>
          <xsl:when test="contains($thesaurus, '▸')">
            <xsl:value-of select="concat('4. ', translate(translate($thesaurus/@n, '/', '／'), '_', ' '))" />
          </xsl:when>
          <xsl:when test="contains($thesaurus, '*')">
            <xsl:value-of select="concat('4. ', translate(translate($thesaurus/ancestor::tei:category/tei:catDesc[contains(., '▸')]/@n, '/', '／'), '_', ' '))" />
          </xsl:when>
        </xsl:choose>
      </field>
      </xsl:if>
      <!-\- Third level -\->
      <xsl:if test="contains($thesaurus, '◦') or contains($thesaurus, '▸') or contains($thesaurus, '*')">
        <field name="mentioned_keywords">
        <xsl:choose>
          <xsl:when test="contains($thesaurus, '◦')">
            <xsl:value-of select="concat('3. ', translate(translate($thesaurus/@n, '/', '／'), '_', ' '))" />
          </xsl:when>
          <xsl:when test="contains($thesaurus, '▸') or contains($thesaurus, '*')">
            <xsl:value-of select="concat('3. ', translate(translate($thesaurus/ancestor::tei:category/tei:catDesc[contains(., '◦')]/@n, '/', '／'), '_', ' '))" />
          </xsl:when>
        </xsl:choose>
      </field>
      </xsl:if>
      <!-\- Second level -\->
      <xsl:if test="contains($thesaurus, '•') or contains($thesaurus, '◦') or contains($thesaurus, '▸') or contains($thesaurus, '*')">
        <field name="mentioned_keywords">
          <xsl:choose>
            <xsl:when test="contains($thesaurus, '•')">
              <xsl:value-of select="concat('2. ', translate(translate($thesaurus/@n, '/', '／'), '_', ' '))" />
            </xsl:when>
          <xsl:when test="contains($thesaurus, '◦') or contains($thesaurus, '▸') or contains($thesaurus, '*')">
            <xsl:value-of select="concat('2. ', translate(translate($thesaurus/ancestor::tei:category/tei:catDesc[contains(., '•')]/@n, '/', '／'), '_', ' '))" />
          </xsl:when>
        </xsl:choose>
        </field>
      </xsl:if>
      <!-\- First level -\->
      <field name="mentioned_keywords">
        <xsl:choose>
          <xsl:when test="contains($thesaurus, '•') or contains($thesaurus, '◦') or contains($thesaurus, '▸') or contains($thesaurus, '*')">
            <xsl:value-of select="concat('1. ', translate(translate($thesaurus/ancestor::tei:category/tei:catDesc[not(contains(., '•'))][not(contains(., '◦'))][not(contains(., '▸'))][not(contains(., '*'))]/@n, '/', '／'), '_', ' '))" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat('1. ', translate(translate($thesaurus/@n, '/', '／'), '_', ' '))" />
          </xsl:otherwise>
        </xsl:choose>
      </field>-->
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="tei:rs[@key!='']" mode="facet_mentioned_keywords_-_categories">
    <xsl:variable name="keyvalue">
      <xsl:choose>
        <xsl:when test="starts-with(@key, ' ')"><xsl:value-of select="substring(normalize-space(@key), 2)"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="normalize-space(@key)"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:for-each select="tokenize($keyvalue, ' #')">
      <xsl:variable name="key" select="translate(., '#', '')"/>
      <xsl:variable name="thesaurus" select="document('../../content/fiscus_framework/resources/thesaurus.xml')//tei:catDesc[lower-case(@n)=lower-case($key)]"/>
      <xsl:if test="contains($thesaurus, '*')">
        <!-- Fifth level -->
        <field name="mentioned_keywords_-_categories">
          <xsl:value-of select="concat('5. ', translate(translate($thesaurus/@n, '/', '／'), '_', ' '))" />
        </field>
      </xsl:if>
      <xsl:if test="contains($thesaurus, '▸') or contains($thesaurus, '*')">
        <!-- Fourth level -->
        <field name="mentioned_keywords_-_categories">
          <xsl:choose>
            <xsl:when test="contains($thesaurus, '▸')">
              <xsl:value-of select="concat('4. ', translate(translate($thesaurus/@n, '/', '／'), '_', ' '))" />
            </xsl:when>
            <xsl:when test="contains($thesaurus, '*')">
              <xsl:value-of select="concat('4. ', translate(translate($thesaurus/ancestor::tei:category/tei:catDesc[contains(., '▸')]/@n, '/', '／'), '_', ' '))" />
            </xsl:when>
          </xsl:choose>
        </field>
      </xsl:if>
      <!-- Third level -->
      <xsl:if test="contains($thesaurus, '◦') or contains($thesaurus, '▸') or contains($thesaurus, '*')">
        <field name="mentioned_keywords_-_categories">
          <xsl:choose>
            <xsl:when test="contains($thesaurus, '◦')">
              <xsl:value-of select="concat('3. ', translate(translate($thesaurus/@n, '/', '／'), '_', ' '))" />
            </xsl:when>
            <xsl:when test="contains($thesaurus, '▸') or contains($thesaurus, '*')">
              <xsl:value-of select="concat('3. ', translate(translate($thesaurus/ancestor::tei:category/tei:catDesc[contains(., '◦')]/@n, '/', '／'), '_', ' '))" />
            </xsl:when>
          </xsl:choose>
        </field>
      </xsl:if>
      <!-- Second level -->
      <xsl:if test="contains($thesaurus, '•') or contains($thesaurus, '◦') or contains($thesaurus, '▸') or contains($thesaurus, '*')">
        <field name="mentioned_keywords_-_categories">
          <xsl:choose>
            <xsl:when test="contains($thesaurus, '•')">
              <xsl:value-of select="concat('2. ', translate(translate($thesaurus/@n, '/', '／'), '_', ' '))" />
            </xsl:when>
            <xsl:when test="contains($thesaurus, '◦') or contains($thesaurus, '▸') or contains($thesaurus, '*')">
              <xsl:value-of select="concat('2. ', translate(translate($thesaurus/ancestor::tei:category/tei:catDesc[contains(., '•')]/@n, '/', '／'), '_', ' '))" />
            </xsl:when>
          </xsl:choose>
        </field>
      </xsl:if>
      <!-- First level -->
      <field name="mentioned_keywords_-_categories">
        <xsl:choose>
          <xsl:when test="contains($thesaurus, '•') or contains($thesaurus, '◦') or contains($thesaurus, '▸') or contains($thesaurus, '*')">
            <xsl:value-of select="concat('1. ', translate(translate($thesaurus/ancestor::tei:category/tei:catDesc[not(contains(., '•'))][not(contains(., '◦'))][not(contains(., '▸'))][not(contains(., '*'))]/@n, '/', '／'), '_', ' '))" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat('1. ', translate(translate($thesaurus/@n, '/', '／'), '_', ' '))" />
          </xsl:otherwise>
        </xsl:choose>
      </field>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="tei:persName[@ref!='']" mode="facet_mentioned_people">
    <field name="mentioned_people">
      <xsl:variable name="ref" select="translate(@ref,' #', '')"/>
      <xsl:choose>
        <xsl:when test="document('../../content/fiscus_framework/resources/people.xml')//tei:person[descendant::tei:idno=$ref][descendant::tei:persName!='']">
          <xsl:variable name="name" select="normalize-space(translate(translate(document('../../content/fiscus_framework/resources/people.xml')//tei:person[descendant::tei:idno=$ref][1]/tei:persName[1], '/', '／'), '?', ''))"/>
          <xsl:value-of select="upper-case(substring($name, 1, 1))"/>
          <xsl:value-of select="substring($name, 2)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="translate(@ref,' #', '')"/>
        </xsl:otherwise>
      </xsl:choose>
    </field>
  </xsl:template>
  
  <xsl:template match="tei:placeName[@ref!='']" mode="facet_mentioned_places">
    <field name="mentioned_places">
      <xsl:variable name="ref" select="translate(@ref,' #', '')"/>
      <xsl:choose>
        <xsl:when test="document('../../content/fiscus_framework/resources/places.xml')//tei:place[descendant::tei:idno=$ref][descendant::tei:placeName[not(@type)]!='']">
          <xsl:variable name="name" select="normalize-space(translate(translate(document('../../content/fiscus_framework/resources/places.xml')//tei:place[descendant::tei:idno=$ref][1]/tei:placeName[not(@type)][1], '/', '／'), '?', ''))"/>
          <xsl:value-of select="upper-case(substring($name, 1, 1))"/>
          <xsl:value-of select="substring($name, 2)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="translate(@ref,' #', '')"/>
        </xsl:otherwise>
      </xsl:choose>
    </field>
  </xsl:template>
  
  <xsl:template match="tei:orgName[@ref!='']" mode="facet_mentioned_juridical_persons">
    <field name="mentioned_juridical_persons">
      <xsl:variable name="ref" select="translate(@ref,' #', '')"/>
      <xsl:choose>
        <xsl:when test="document('../../content/fiscus_framework/resources/juridical_persons.xml')//tei:org[descendant::tei:idno=$ref][descendant::tei:orgName!='']">
          <xsl:variable name="name" select="normalize-space(translate(translate(document('../../content/fiscus_framework/resources/juridical_persons.xml')//tei:org[descendant::tei:idno=$ref][1]/tei:orgName[1], '/', '／'), '?', ''))"/>
          <xsl:value-of select="upper-case(substring($name, 1, 1))"/>
          <xsl:value-of select="substring($name, 2)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="translate(@ref,' #', '')"/>
        </xsl:otherwise>
      </xsl:choose>
    </field>
  </xsl:template>
  
  <xsl:template match="tei:geogName[@ref!='']" mode="facet_mentioned_estates">
    <field name="mentioned_estates">
      <xsl:variable name="ref" select="translate(@ref,' #', '')"/>
      <xsl:choose>
        <xsl:when test="document('../../content/fiscus_framework/resources/estates.xml')//tei:place[descendant::tei:idno=$ref][descendant::tei:geogName!='']">
          <xsl:variable name="name" select="normalize-space(translate(translate(document('../../content/fiscus_framework/resources/estates.xml')//tei:place[descendant::tei:idno=$ref][1]/tei:geogName[1], '/', '／'), '?', ''))"/>
          <xsl:value-of select="upper-case(substring($name, 1, 1))"/>
          <xsl:value-of select="substring($name, 2)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="translate(@ref,' #', '')"/>
        </xsl:otherwise>
      </xsl:choose>
    </field>
  </xsl:template>
  
  <xsl:template match="tei:date" mode="facet_mentioned_dates">
    <field name="mentioned_dates">
      <xsl:value-of select="translate(translate(., '/', '／'), '?', '')" />
    </field>
  </xsl:template>
  
  <xsl:template match="tei:persName/tei:name[@nymRef]" mode="facet_person_name">
    <field name="person_name">
      <xsl:value-of select="@nymRef"/>
    </field>
  </xsl:template>
  
  <xsl:template match="tei:TEI" mode="facet_complete_edition">
    <field name="complete_edition"> 
      <xsl:apply-templates select="." />
    </field>
  </xsl:template>
  
  <!-- This template is called by the Kiln tei-to-solr.xsl as part of
       the main doc for the indexed file. Put any code to generate
       additional Solr field data (such as new facets) here. -->
  
  <xsl:template name="extra_fields">
    <xsl:call-template name="field_ancient_document_type"/>
    <xsl:call-template name="field_fiscal_property"/>
    <xsl:call-template name="field_record_source"/>
    <xsl:call-template name="field_document_tradition" />
    <xsl:call-template name="field_topical_date"/>
    <xsl:call-template name="field_redaction_date"/>
    <xsl:call-template name="field_mentioned_keywords_-_categories"/>
    <xsl:call-template name="field_mentioned_keywords_-_terms"/>
    <xsl:call-template name="field_mentioned_people"/>
    <xsl:call-template name="field_mentioned_places"/>
    <xsl:call-template name="field_mentioned_juridical_persons"/>
    <xsl:call-template name="field_mentioned_estates"/>
    <xsl:call-template name="field_mentioned_dates"/>
    <xsl:call-template name="field_person_name"/>
    <xsl:call-template name="field_complete_edition"/>
  </xsl:template>
  
  <xsl:template name="field_ancient_document_type">
    <xsl:apply-templates mode="facet_ancient_document_type" select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msContents/tei:summary/tei:rs[@type='text_type']"/>
  </xsl:template>
  
  <xsl:template name="field_fiscal_property">
    <xsl:apply-templates mode="facet_fiscal_property" select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msContents/tei:summary/tei:rs[@type='fiscal_property']" />
  </xsl:template>
  
  <xsl:template name="field_record_source">
    <xsl:apply-templates mode="facet_record_source" select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msContents/tei:summary/tei:rs[@type='record_source']"/>
  </xsl:template>
  
  <xsl:template name="field_document_tradition">
    <xsl:apply-templates mode="facet_document_tradition" select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msContents/tei:summary/tei:rs[@type='document_tradition']" />
  </xsl:template>
  
  <xsl:template name="field_topical_date">
    <xsl:apply-templates mode="facet_topical_date" select="/tei:TEI/tei:teiHeader//tei:origDate/tei:note[@type='topical_date']"/>
  </xsl:template>
  
  <xsl:template name="field_redaction_date">
    <xsl:apply-templates mode="facet_redaction_date" select="/tei:TEI/tei:teiHeader//tei:origDate/tei:note[@type='redaction_date']"/>
  </xsl:template>
  
  <xsl:template name="field_mentioned_keywords_-_categories">
    <xsl:apply-templates mode="facet_mentioned_keywords_-_categories" select="//tei:text/tei:body/tei:div[@type='edition']"/>
  </xsl:template>
  
  <xsl:template name="field_mentioned_keywords_-_terms">
    <xsl:apply-templates mode="facet_mentioned_keywords_-_terms" select="//tei:text/tei:body/tei:div[@type='edition']"/>
  </xsl:template>
  
  <xsl:template name="field_mentioned_people">
    <xsl:apply-templates mode="facet_mentioned_people" select="//tei:text/tei:body/tei:div[@type='edition']" />
  </xsl:template>
  
  <xsl:template name="field_mentioned_places">
    <xsl:apply-templates mode="facet_mentioned_places" select="//tei:text/tei:body/tei:div[@type='edition']" />
  </xsl:template>
  
  <xsl:template name="field_mentioned_juridical_persons">
    <xsl:apply-templates mode="facet_mentioned_juridical_persons" select="//tei:text/tei:body/tei:div[@type='edition']" />
  </xsl:template>
  
  <xsl:template name="field_mentioned_estates">
    <xsl:apply-templates mode="facet_mentioned_estates" select="//tei:text/tei:body/tei:div[@type='edition']" />
   </xsl:template>
  
  <xsl:template name="field_mentioned_dates">
    <xsl:apply-templates mode="facet_mentioned_dates" select="//tei:text/tei:body/tei:div[@type='edition']" />
  </xsl:template>
  
  <xsl:template name="field_person_name">
    <xsl:apply-templates mode="facet_person_name" select="//tei:text/tei:body/tei:div[@type='edition']" />
  </xsl:template>
  
  <xsl:template name="field_complete_edition">
    <xsl:apply-templates mode="facet_complete_edition" select="/tei:TEI" />
  </xsl:template>

</xsl:stylesheet>
