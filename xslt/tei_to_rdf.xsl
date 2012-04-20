<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xml="http://www.w3.org/XML/1998/namespace">
  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
  <xsl:variable name="MAN_ID" select="/tei:TEI/@xml:id"/>
  <xsl:variable name="CONFORMATION" select="/tei:TEI/namespace::node()"/>
  <xsl:template match="/">
    <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
      xmlns:dct="http://purl.org/dc/terms/">
      <!-- Creation of RDF statements describing the document as a whole  -->
      <rdf:Description>
        <xsl:attribute name="rdf:about">
          <xsl:value-of select="$MAN_ID"/>
        </xsl:attribute>
        <xsl:for-each select="/tei:fileDesc/tei:titleStmt//tei:title">
          <dct:title>
            <xsl:value-of select="."/>
          </dct:title>
        </xsl:for-each>

        <xsl:for-each select="//tei:author">
          <xsl:if test="text() [normalize-space(.) ]">
            <dct:creator>
              <xsl:value-of select="text()"/>
            </dct:creator>
          </xsl:if>
        </xsl:for-each>

        <xsl:for-each select="//tei:publicationStmt/tei:p">
          <dct:publisher>
            <xsl:value-of select="."/>
          </dct:publisher>
        </xsl:for-each>

        <dct:type>TEI/XML</dct:type>
        <dct:conformsTo>
          <xsl:value-of select="$CONFORMATION"/>
        </dct:conformsTo>
        <xsl:for-each select="/tei:TEI//tei:body/@xml:id">
          <dct:hasPart>
            <xsl:value-of select="."/>
          </dct:hasPart>
        </xsl:for-each>
      </rdf:Description>

      <!-- add rdf for author title - the only element from the head tag needing its own descriptive element -->
      <xsl:for-each select="//tei:author/tei:title">
        <xsl:if test="text() [normalize-space(.) ]">
          <xsl:variable name="ABOUT" select="."/>
          <xsl:variable name="PARENT" select="./../@xml:id"/>
          <rdf:Description>
            <xsl:attribute name="rdf:about">
              <xsl:value-of select="$ABOUT"/>
            </xsl:attribute>
            <dct:isPartOf>
              <xsl:value-of select="$PARENT"/>
            </dct:isPartOf>
          </rdf:Description>
        </xsl:if>
      </xsl:for-each>


      <!--  Simplified extraction.  The first stage locates all elements, and creates RDF relationship to that elements immediate parent  -->



      <!-- Creation of RDF statements describing Text level divisions  -->
      <xsl:for-each select="/tei:TEI/tei:text//tei:body">
        <xsl:variable name="ABOUT" select="/tei:TEI/tei:text//tei:body/@xml:id"/>
        <rdf:Description>
          <xsl:attribute name="rdf:about">
            <xsl:value-of select="$ABOUT"/>
          </xsl:attribute>
          <dct:isPartOf>
            <xsl:value-of select="$MAN_ID"/>
          </dct:isPartOf>
        </rdf:Description>
      </xsl:for-each>
      <!-- establish relationships from paragraph elements back to body tag  -->
      <xsl:for-each select="//tei:body//tei:p | //tei:body//tei:div | //tei:author">
        <rdf:Description>
          <xsl:attribute name="rdf:about">
            <xsl:value-of select="./@xml:id"/>
          </xsl:attribute>
          <dct:isPartOf>
            <xsl:value-of select="./../@xml:id"/>
          </dct:isPartOf>
        </rdf:Description>
        <rdf:Description>
          <xsl:attribute name="rdf:about">
            <xsl:value-of select="./../@xml:id"/>
          </xsl:attribute>
          <dct:hasPart>
            <xsl:value-of select="./@xml:id"/>
          </dct:hasPart>
        </rdf:Description>
      </xsl:for-each>
    </rdf:RDF>

  </xsl:template>



</xsl:stylesheet>
