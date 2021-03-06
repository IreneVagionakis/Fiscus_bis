<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all"
                version="2.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:param name="base-uri" />

  <xsl:template name="field_file_path">
    <!-- The file_path field for user indices should be the same for
         all indices defined in the same index file, as they are all
         indexed together and so existing entries need to be deleted
         together. -->
    <field name="file_path">
      <xsl:text>indices/</xsl:text>
      <xsl:value-of select="$subdirectory" />
    </field>
  </xsl:template>

  <xsl:template name="field_index_instance_location">
    <field name="index_instance_location">
      <!-- This field contains a combination of the following:

             * The content/xml subdirectory containing the indexed
             field, to be used in generating the map:match id used in
             generating the URL of the document containing this
             instance, via kiln:url-for-match. (This is the
             $subdirectory parameter.)

             * The path to the file (minus extension) this instance
             belongs to, relative to the content subdirectory (ie, the
             value in the preceding item), to be passed to the
             kiln:url-for-match call to generate the URL of the
             document containing this instance.

             * The text part numbers in descending hierarchical
             sequence for the instance, separated by ".".

             * The line number of the instance.

             * A Boolean marker (0 or 1) marking if the instance is
             partially or completely restored (1) or not (0).

           Each part is separated by "#" for parsing in the query
           results.

      -->
      <xsl:variable name="filepath" select="substring-before(ancestor::file[1]/@path, '.xml')" />
      <xsl:value-of select="$subdirectory" />
      <xsl:text>#</xsl:text>
      <xsl:value-of select="$filepath" />
      <xsl:text>#</xsl:text>
      <xsl:choose>
        <xsl:when test="ancestor::tei:TEI/tei:teiHeader//tei:origDate[@when!=''][@when!='0001']"><xsl:value-of select="ancestor::tei:TEI/tei:teiHeader//tei:origDate/@when" /></xsl:when>
        <xsl:otherwise>
              <xsl:value-of select="ancestor::tei:TEI/tei:teiHeader//tei:origDate/@notBefore" />
          <xsl:text>–</xsl:text>
              <xsl:value-of select="ancestor::tei:TEI/tei:teiHeader//tei:origDate/@notAfter" />
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>#</xsl:text>
      <xsl:choose>
        <xsl:when test="@key!='' and not(self::tei:rs)"><xsl:value-of select="lower-case(translate(replace(translate(@key, '_', ' '), ' #', '; '), '#', ''))"/></xsl:when>
        <xsl:otherwise><xsl:text>~</xsl:text></xsl:otherwise>
      </xsl:choose>
      <!--<xsl:text>#</xsl:text>
      <xsl:variable name="ancestor_place"><xsl:for-each select="ancestor::tei:placeName/@ref "><xsl:value-of select="translate(.,'#','')"/></xsl:for-each></xsl:variable>
      <xsl:variable name="ancestor_person"><xsl:for-each select="ancestor::tei:persName/@ref "><xsl:value-of select="translate(.,'#','')"/></xsl:for-each></xsl:variable>
      <xsl:variable name="ancestor_org"><xsl:for-each select="ancestor::tei:orgName/@ref "><xsl:value-of select="translate(.,'#','')"/></xsl:for-each></xsl:variable>
      <xsl:variable name="ancestor_geog"><xsl:for-each select="ancestor::tei:geogName/@ref "><xsl:value-of select="translate(.,'#','')"/></xsl:for-each></xsl:variable>
      <xsl:variable name="descendant_place"><xsl:for-each select="ancestor::tei:placeName/@ref "><xsl:value-of select="translate(.,'#','')"/></xsl:for-each></xsl:variable>
      <xsl:variable name="descendant_person"><xsl:for-each select="ancestor::tei:persName/@ref "><xsl:value-of select="translate(.,'#','')"/></xsl:for-each></xsl:variable>
      <xsl:variable name="descendant_org"><xsl:for-each select="ancestor::tei:orgName/@ref "><xsl:value-of select="translate(.,'#','')"/></xsl:for-each></xsl:variable>
      <xsl:variable name="descendant_geog"><xsl:for-each select="ancestor::tei:geogName/@ref "><xsl:value-of select="translate(.,'#','')"/></xsl:for-each></xsl:variable>
      <xsl:variable name="place_ancestor" select="document(concat('file:',system-property('user.dir'),'/webapps/ROOT/content/fiscus_framework/resources/places.xml'))//tei:listPlace/tei:place[tei:idno=$ancestor_place][1]/tei:placeName[1]"/>
      <xsl:variable name="estate_ancestor" select="document(concat('file:',system-property('user.dir'),'/webapps/ROOT/content/fiscus_framework/resources/estates.xml'))//tei:listPlace/tei:place[tei:idno=$ancestor_geog][1]/tei:geogName[1]"/>
      <xsl:variable name="person_ancestor" select="document(concat('file:',system-property('user.dir'),'/webapps/ROOT/content/fiscus_framework/resources/people.xml'))//tei:listPerson/tei:person[tei:idno=$ancestor_person][1]/tei:persName[1]"/>
      <xsl:variable name="juridical_person_ancestor" select="document(concat('file:',system-property('user.dir'),'/webapps/ROOT/content/fiscus_framework/resources/juridical_persons.xml'))//tei:listOrg/tei:org[tei:idno=$ancestor_org][1]/tei:orgName[1]"/>
      <xsl:variable name="place_descendant" select="document(concat('file:',system-property('user.dir'),'/webapps/ROOT/content/fiscus_framework/resources/places.xml'))//tei:listPlace/tei:place[tei:idno=$descendant_place][1]/tei:placeName[1]"/>
      <xsl:variable name="estate_descendant" select="document(concat('file:',system-property('user.dir'),'/webapps/ROOT/content/fiscus_framework/resources/estates.xml'))//tei:listPlace/tei:place[tei:idno=$descendant_geog][1]/tei:geogName[1]"/>
      <xsl:variable name="person_descendant" select="document(concat('file:',system-property('user.dir'),'/webapps/ROOT/content/fiscus_framework/resources/people.xml'))//tei:listPerson/tei:person[tei:idno=$descendant_person][1]/tei:persName[1]"/>
      <xsl:variable name="juridical_person_descendant" select="document(concat('file:',system-property('user.dir'),'/webapps/ROOT/content/fiscus_framework/resources/juridical_persons.xml'))//tei:listOrg/tei:org[tei:idno=$descendant_org][1]/tei:orgName[1]"/>
      <xsl:if test="ancestor::tei:persName[@ref]"><xsl:text> </xsl:text><xsl:value-of select="$person_ancestor"/></xsl:if>
      <xsl:if test="ancestor::tei:placeName[@ref]"><xsl:text> </xsl:text><xsl:value-of select="$place_ancestor"/></xsl:if>
      <xsl:if test="ancestor::tei:orgName[@ref]"><xsl:text> </xsl:text><xsl:value-of select="$juridical_person_ancestor"/></xsl:if>
      <xsl:if test="ancestor::tei:geogName[@ref]"><xsl:text> </xsl:text><xsl:value-of select="$estate_ancestor"/></xsl:if>
      <xsl:if test="descendant::tei:persName[@ref]"><xsl:text> </xsl:text><xsl:value-of select="$person_descendant"/></xsl:if>
      <xsl:if test="descendant::tei:placeName[@ref]"><xsl:text> </xsl:text><xsl:value-of select="$place_descendant"/></xsl:if>
      <xsl:if test="descendant::tei:orgName[@ref]"><xsl:text> </xsl:text><xsl:value-of select="$juridical_person_descendant"/></xsl:if>
      <xsl:if test="descendant::tei:geogName[@ref]"><xsl:text> </xsl:text><xsl:value-of select="$estate_descendant"/></xsl:if>-->
    </field>
  </xsl:template>

</xsl:stylesheet>
