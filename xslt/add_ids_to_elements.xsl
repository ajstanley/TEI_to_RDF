<?xml version="1.0"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.tei-c.org/ns/1.0"
  version="2.0">

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="no"/>

<!-- XSLT to allocate each element in a TEI/XML document a distinct xml:id, 
     if that element does not already have an xml:id attribute. 
     Taken from an XSTL originally provided by Charlotte Tupman, Department 
     of Digital Humanities, King's College London, for the SAWS project 
     (http://www.ancientwisdoms.ac.uk) -->
  
  <!-- In general, to extract RDF from TEI/XML documents using one of the 
       accompanying tei-to-rdf stylesheets, transform the TEI document using 
       this XSLT first, then apply a tei-to-rdf transform to this output. 
       This is unless you have already allocated xml:ids to every element 
       in your original TEI document. -->

  <!-- ||||||||||||||||||||||||||||||||||||||||||||||| -->
  <!-- |||||||||  copy all existing elements ||||||||| -->
  <!-- ||||||||||||||||||||||||||||||||||||||||||||||| -->

  <xsl:template match="*">
    <xsl:element name="{local-name()}">
      <xsl:copy-of select="@*"/>
      
      <!-- if the current node does not have an xml:id attribute, 
           generate one and add it to the XSLT output document -->
      <xsl:if test="not(attribute::xml:id)">
        <xsl:attribute name="xml:id">
          <xsl:value-of select="concat(name(),'_',generate-id())"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <!-- |||||||||||||||||||||||||||||||||||||||||||||||||||| -->
  <!-- |||||||||||||||| copy processing instruction  |||||||||||||||| -->
  <!-- |||||||||||||||||||||||||||||||||||||||||||||||||||| -->

  <xsl:template match="//processing-instruction()">
    <xsl:text>
</xsl:text>
    <xsl:copy>
      <xsl:value-of select="."/>
    </xsl:copy>
    <xsl:text>
</xsl:text>
  </xsl:template>

  <!-- |||||||||||||||||||||||||||||||||||||||||||||||||||| -->
  <!-- |||||||||||||||| copy all comments  |||||||||||||||| -->
  <!-- |||||||||||||||||||||||||||||||||||||||||||||||||||| -->

  <xsl:template match="comment()">
    <xsl:copy>
      <xsl:value-of select="."/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
