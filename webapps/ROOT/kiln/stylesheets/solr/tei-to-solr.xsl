<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all"
                version="2.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- This XSLT transforms a TEI document into a Solr index
       document. -->

  <!-- Path to the TEI file being indexed. -->
  <xsl:param name="file-path" />

  <xsl:variable name="document-metadata">
    <xsl:apply-templates mode="document-metadata" select="/*/tei:teiHeader" />
  </xsl:variable>

  <xsl:variable name="free-text">
    <xsl:apply-templates mode="free-text" select="/*/tei:text" />
  </xsl:variable>

  <xsl:template match="/">
    <!-- Entity mentions are restricted to the text of the document;
         entities keyed in the TEI header are document metadata. -->
    <xsl:apply-templates mode="entity-mention" select="/*/tei:text//tei:*[@key]" />

    <!-- Text content -->
    <xsl:if test="normalize-space($free-text)">
      <doc>
        <xsl:sequence select="$document-metadata" />
        <xsl:call-template name="field_document_type" />
        <xsl:call-template name="field_file_path" />
        <xsl:call-template name="field_document_id" />
        <xsl:call-template name="field_text" />
        <xsl:call-template name="field_lemmatised_text" />
        <!-- Facets. -->
        <xsl:call-template name="field_author" />
        <xsl:call-template name="field_mentioned_persons" />
        <xsl:call-template name="field_mentioned_people" />
        <xsl:call-template name="field_mentioned_places" />
        <xsl:call-template name="field_provenance" />
        <xsl:call-template name="field_record_source"/>
        <xsl:call-template name="field_fiscal_property" />
        <xsl:call-template name="field_document_tradition" />
        <xsl:call-template name="field_mentioned_juridical_persons"/>
        <xsl:call-template name="field_topical_date"/>
        <xsl:call-template name="extra_fields" />
      </doc>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:fileDesc/tei:titleStmt/tei:title" mode="document-metadata">
    <field name="document_title">
      <xsl:value-of select="normalize-space(.)" />
    </field>
  </xsl:template>

  <xsl:template match="tei:listChange/tei:change[1]" mode="facet_author">
    <field name="author">
      <xsl:choose>
        <xsl:when test="contains(lower-case(@who), 'admin')"><xsl:text>Admin Fiscus</xsl:text></xsl:when>
        <xsl:when test="contains(lower-case(@who), 'fiscus')"><xsl:text>Admin Fiscus</xsl:text></xsl:when>
        <xsl:when test="contains(lower-case(@who), 'salvaterra')"><xsl:text>Carla Salvaterra</xsl:text></xsl:when>
        <xsl:when test="contains(lower-case(@who), 'lazzari')"><xsl:text>Tiziana Lazzari</xsl:text></xsl:when>
        <xsl:when test="contains(lower-case(@who), 'tabarrini')"><xsl:text>Lorenzo Tabarrini</xsl:text></xsl:when>
        <xsl:when test="contains(lower-case(@who), 'vignodelli')"><xsl:text>Giacomo Vignodelli</xsl:text></xsl:when>
        <xsl:when test="contains(lower-case(@who), 'collavini')"><xsl:text>Simone Maria Collavini</xsl:text></xsl:when>
        <xsl:when test="contains(lower-case(@who), 'tomei')"><xsl:text>Paolo Tomei</xsl:text></xsl:when>
        <xsl:when test="contains(lower-case(@who), 'internullo')"><xsl:text>Dario Internullo</xsl:text></xsl:when>
        <xsl:when test="contains(lower-case(@who), 'vlore')"><xsl:text>Vito Loré</xsl:text></xsl:when>
        <xsl:when test="contains(lower-case(@who), 'ciccopiedi')"><xsl:text>Caterina Ciccopiedi</xsl:text></xsl:when>
        <xsl:when test="contains(lower-case(@who), 'manarini')"><xsl:text>Edoardo Manarini</xsl:text></xsl:when>
        <xsl:when test="contains(lower-case(@who), 'vallerani')"><xsl:text>Massimo Valerio Vallerani</xsl:text></xsl:when>
        <xsl:when test="contains(lower-case(@who), 'cinello')"><xsl:text>Erika Cinello</xsl:text></xsl:when>
        <xsl:when test="contains(lower-case(@who), 'tagliente')"><xsl:text>Antonio Tagliente</xsl:text></xsl:when>
        <xsl:when test="contains(lower-case(@who), 'zornetta')"><xsl:text>Giulia Zornetta</xsl:text></xsl:when>
        <xsl:when test="contains(lower-case(@who), 'dimuro')"><xsl:text>Alessandro Di Muro</xsl:text></xsl:when>
        <xsl:when test="contains(lower-case(@who), 'magos')"><xsl:text>Victor Rivera Magos</xsl:text></xsl:when>
        <xsl:when test="contains(lower-case(@who), 'motta')"><xsl:text>Loris Motta</xsl:text></xsl:when>
        <xsl:when test="contains(lower-case(@who), 'defalco')"><xsl:text>Fabrizio De Falco</xsl:text></xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="@who"><xsl:value-of select="@who"/></xsl:when>
            <xsl:otherwise><xsl:text>-</xsl:text></xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </field>
  </xsl:template>

  <xsl:template match="tei:fileDesc/tei:titleStmt/tei:editor" mode="document-metadata">
    <field name="editor">
      <xsl:value-of select="normalize-space(.)" />
    </field>
  </xsl:template>

  <xsl:template match="tei:sourceDesc//tei:publicationStmt/tei:date[1]"
                mode="document-metadata">
    <xsl:if test="@when">
      <field name="publication_date">
        <xsl:value-of select="@when" />
      </field>
    </xsl:if>
  </xsl:template>

  <!-- For all origDates, use only the year. -->
  <xsl:template match="tei:origDate[@when][not(@notBefore)][not(@notAfter)]|tei:origDate[@when!='0001'][@notBefore='0001']|tei:origDate[@when!='0001'][@notAfter='0001']" mode="document-metadata">
    <xsl:variable name="year">
      <xsl:call-template name="get-year-from-date">
        <xsl:with-param name="date" select="@when" />
      </xsl:call-template>
    </xsl:variable>
    <field name="origin_date">
      <xsl:value-of select="$year" />
    </field>
  </xsl:template>

  <!-- If @notBefore is specified, @notAfter is assumed to be
       specified, and vice versa. -->
  <xsl:template match="tei:origDate[@notBefore][@notAfter][not(@when)]|tei:origDate[@notBefore!='0001'][@notAfter!='0001'][@when='0001']" mode="document-metadata">
    <xsl:variable name="start-year">
      <xsl:call-template name="get-year-from-date">
        <xsl:with-param name="date" select="@notBefore" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="end-year">
      <xsl:call-template name="get-year-from-date">
        <xsl:with-param name="date" select="@notAfter" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:for-each select="($start-year to $end-year)">
      <field name="origin_date">
        <xsl:value-of select="." />
      </field>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="text()" mode="document-metadata" />

  <xsl:template match="node()" mode="free-text">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="@lemma" mode="lemma">
    <xsl:value-of select="." />
    <xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template match="@nymRef" mode="lemma">
    <!-- Only support local references; to add in external references
         would require determining what they are at an earlier step in
         the pipeline and XIncluding the referenced documents. This
         would be a significant change to the existing indexing
         pipeline and XSLT. -->
    <xsl:variable name="root" select="/" />
    <xsl:for-each select="tokenize(., '\s+')">
      <xsl:if test="starts-with(., '#')">
        <!-- Since we have no idea what markup is at the end of this
             reference, just take the text value. -->
        <xsl:value-of select="$root/id(substring-after(current(), '#'))" />
        <xsl:text> </xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="node()|@*" mode="lemma">
    <xsl:apply-templates mode="lemma" select="@*|node()" />
  </xsl:template>

  <xsl:template match="tei:*[@key]" mode="entity-mention">
    <doc>
      <xsl:sequence select="$document-metadata" />

      <xsl:call-template name="field_file_path" />
      <xsl:call-template name="field_document_id" />
      <field name="section_id">
        <xsl:value-of select="ancestor::tei:*[self::tei:div or self::tei:body or self::tei:front or self::tei:back or self::tei:group or self::tei:text][@xml:id][1]/@xml:id" />
      </field>
      <field name="entity_key">
        <xsl:value-of select="@key" />
      </field>
      <field name="entity_name">
        <xsl:value-of select="normalize-space(.)" />
      </field>
    </doc>
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

  <xsl:template match="//tei:origPlace" mode="facet_provenance">
    <!-- This does nothing to prevent duplicate instances of the same
         @ref value being recorded. -->
    <field name="provenance">
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
  
  <xsl:template match="tei:orgName[@ref!='']" mode="facet_mentioned_juridical_persons">
      <field name="mentioned_juridical_persons">
        <xsl:variable name="ref" select="translate(@ref,' #', '')"/>
        <xsl:choose>
          <xsl:when test="document('../../../content/fiscus_framework/resources/juridical_persons.xml')//tei:org[descendant::tei:idno=$ref]">
            <xsl:variable name="name" select="normalize-space(translate(document('../../../content/fiscus_framework/resources/juridical_persons.xml')//tei:org[descendant::tei:idno=$ref][1]/tei:orgName[1], '/', '／'))"/>
            <xsl:value-of select="upper-case(substring($name, 1, 1))"/>
            <xsl:value-of select="substring($name, 2)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="translate(@ref,' #', '')"/>
          </xsl:otherwise>
        </xsl:choose>
      </field>
  </xsl:template>
  
  <xsl:template match="tei:origDate/tei:note[@type='topical_date']" mode="facet_topical_date">
    <field name="topical_date">
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

  <xsl:template match="tei:persName[@ref!='']" mode="facet_mentioned_persons">
    <field name="mentioned_persons">
      <xsl:variable name="ref" select="translate(@ref,' #', '')"/>
      <xsl:choose>
        <xsl:when test="document('../../../content/fiscus_framework/resources/people.xml')//tei:person[descendant::tei:idno=$ref]">
          <xsl:variable name="name" select="normalize-space(translate(document('../../../content/fiscus_framework/resources/people.xml')//tei:person[descendant::tei:idno=$ref][1]/tei:persName[1], '/', '／'))"/>
          <xsl:value-of select="upper-case(substring($name, 1, 1))"/>
          <xsl:value-of select="substring($name, 2)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="translate(@ref,' #', '')"/>
        </xsl:otherwise>
      </xsl:choose>
    </field>
  </xsl:template>

  <xsl:template match="tei:persName[@ref!='']" mode="facet_mentioned_people">
    <field name="mentioned_people">
      <xsl:variable name="ref" select="translate(@ref,' #', '')"/>
      <xsl:choose>
        <xsl:when test="document('../../../content/fiscus_framework/resources/people.xml')//tei:person[descendant::tei:idno=$ref]">
          <xsl:variable name="name" select="normalize-space(translate(document('../../../content/fiscus_framework/resources/people.xml')//tei:person[descendant::tei:idno=$ref][1]/tei:persName[1], '/', '／'))"/>
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
        <xsl:when test="document('../../../content/fiscus_framework/resources/places.xml')//tei:place[descendant::tei:idno=$ref]/tei:placeName[not(@type)]">
          <xsl:variable name="name" select="normalize-space(translate(document('../../../content/fiscus_framework/resources/places.xml')//tei:place[descendant::tei:idno=$ref][1]/tei:placeName[not(@type)][1], '/', '／'))"/>
          <xsl:value-of select="upper-case(substring($name, 1, 1))"/>
          <xsl:value-of select="substring($name, 2)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="translate(@ref,' #', '')"/>
        </xsl:otherwise>
      </xsl:choose>
    </field>
  </xsl:template>

  <xsl:template match="text()" mode="facet_mentioned_places" />

  <xsl:template name="field_document_id">
    <field name="document_id">
      <xsl:variable name="idno" select="/tei:*/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type='filename']" />
      <xsl:choose>
        <xsl:when test="$idno">
          <xsl:value-of select="$idno" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="/tei:*/@xml:id" />
        </xsl:otherwise>
      </xsl:choose>
    </field>
  </xsl:template>

  <xsl:template name="field_document_type">
    <field name="document_type">
      <xsl:value-of select="substring-before($file-path, '/')" />
    </field>
  </xsl:template>

  <xsl:template name="field_file_path">
    <field name="file_path">
      <xsl:value-of select="$file-path" />
    </field>
  </xsl:template>

  <xsl:template name="field_author">
    <xsl:apply-templates mode="facet_author" select="//tei:listChange/tei:change[1]" />
  </xsl:template>
  
  <xsl:template name="field_mentioned_persons">
    <xsl:apply-templates mode="facet_mentioned_persons" select="//tei:text/tei:body/tei:div[@type='edition']" />
  </xsl:template>

  <xsl:template name="field_lemmatised_text">
    <field name="lemmatised_text">
      <xsl:apply-templates mode="lemma" select="//tei:text" />
    </field>
  </xsl:template>

  <xsl:template name="field_mentioned_people">
    <xsl:apply-templates mode="facet_mentioned_people" select="//tei:text/tei:body/tei:div[@type='edition']" />
  </xsl:template>

  <xsl:template name="field_mentioned_places">
    <xsl:apply-templates mode="facet_mentioned_places" select="//tei:text/tei:body/tei:div[@type='edition']" />
  </xsl:template>

  <xsl:template name="field_provenance">
    <xsl:apply-templates mode="facet_provenance" select="//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origPlace" />
  </xsl:template>

  <xsl:template name="field_record_source">
    <xsl:apply-templates mode="facet_record_source" select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msContents/tei:summary/tei:rs[@type='record_source']"/>
  </xsl:template>

  <xsl:template name="field_document_tradition">
    <xsl:apply-templates mode="facet_document_tradition" select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msContents/tei:summary/tei:rs[@type='document_tradition']" />
  </xsl:template>
  
  <xsl:template name="field_mentioned_juridical_persons">
    <xsl:apply-templates mode="facet_mentioned_juridical_persons" select="//tei:text/tei:body/tei:div[@type='edition']//tei:orgName" />
  </xsl:template>
  
  <xsl:template name="field_topical_date">
    <xsl:apply-templates mode="facet_topical_date" select="/tei:TEI/tei:teiHeader//tei:origDate/tei:note[@type='topical_date']"/>
  </xsl:template>

  <xsl:template name="field_fiscal_property">
    <xsl:apply-templates mode="facet_fiscal_property" select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msContents/tei:summary/tei:rs[@type='fiscal_property']" />
  </xsl:template>

  <xsl:template name="field_text">
    <field name="text">
      <xsl:value-of select="normalize-space($free-text)" />
    </field>
  </xsl:template>

  <!-- Return an integer year from a "date", that might be in one of a
       number of formats. Specifically, handles YYYY, YYYY-MM, and
       YYYY-MM-DD, with optional preceding "-". -->
  <xsl:template name="get-year-from-date">
    <xsl:param name="date" />
    <xsl:variable name="parts" select="tokenize(substring($date, 2), '-')" />
    <xsl:variable name="normalised-date">
      <xsl:value-of select="$date" />
      <xsl:choose>
        <xsl:when test="count($parts) = 1">
          <xsl:text>-01-01</xsl:text>
        </xsl:when>
        <xsl:when test="count($parts) = 2">
          <xsl:text>-01</xsl:text>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="year-from-date(xs:date($normalised-date))" />
  </xsl:template>

</xsl:stylesheet>
