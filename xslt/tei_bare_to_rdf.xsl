<?xml version="1.0" encoding="utf-8"?>
<!--  xslt to extract rdf data from TEI-Bare encoded text 
      TEI-Bare is a minimal TEI tagset, i.e. the very basic tags necessary
      to encode a document in TEI
      The TEI-Bare schema can be obtained from http://www.tei-c.org/
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dct="http://purl.org/dc/terms/"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xml="http://www.w3.org/XML/1998/namespace">
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

    <!-- Create a variable to store the manuscript ID -->
    <xsl:variable name="MAN_ID" select="concat('pubNS:',/tei:TEI/@xml:id)"/>

    <!-- Create a variable to store the namespace of the TEI node -->
    <!-- Thanks to Alohci at http://stackoverflow.com/questions/1319138/finding-xmlns-with-xsl-xpath -->
    <xsl:variable name="CONFORMATION" select="/tei:TEI/namespace::*[not (name())]"/>

    <!-- Create a variable to store the namespace declared for RDF triples pointing to 
    locations within the TEI document - this variable should be used whenever a URI is generated 
    to point to an element in the TEI document -->
    <xsl:variable name="DOC_PUB" select="'http://www.example.com/add-default-namespace-here#'"/>

    <!-- Set up output document's root element. 
         Declare namespaces for rdf and for Dublin Core terms.
         Add a dummy namespace doc_ns indicating the default namespace for the published TEI document
         (the correct namespace can later be added to the document (by a global find-and-replace on 
         this dummy namespace), to allow generated RDF URIs to be dereferenceable. -->

    <xsl:template match="/">
        <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
            xmlns:dct="http://purl.org/dc/terms/"
            xmlns:doc_ns="http://www.example.com/add-default-namespace-here#">

            <!-- Creation of RDF statements describing the document as a whole  -->

            <rdf:Description>
                <xsl:attribute name="rdf:about">
                    <xsl:value-of select="concat($DOC_PUB,$MAN_ID)"/>
                </xsl:attribute>
                <xsl:for-each select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt//tei:title">
                    <dct:title>
                        <xsl:value-of select="."/>
                    </dct:title>
                </xsl:for-each>
                <xsl:for-each select="/tei:TEI/tei:teiHeader//tei:author">
                    <xsl:if test="text() [normalize-space(.) ]">
                        <dct:creator>
                            <xsl:value-of select="text()"/>
                        </dct:creator>
                    </xsl:if>
                </xsl:for-each>

                <xsl:for-each select="/tei:TEI/tei:teiHeader//tei:publicationStmt//tei:p">
                    <dct:publisher>
                        <xsl:value-of select="."/>
                    </dct:publisher>
                </xsl:for-each>

                <xsl:for-each select="//tei:sourceDesc/tei:p">
                    <dct:source>
                        <xsl:value-of select="."/>
                    </dct:source>
                </xsl:for-each>
                <dct:type>TEI/XML</dct:type>
                <dct:conformsTo>
                    <xsl:value-of select="$CONFORMATION"/>
                </dct:conformsTo>
                
                <!--  create structural relationships for list elements within SourceDesc tag -->
                <xsl:for-each select="//tei:sourceDesc//tei:list">
                    <dct:source>
                        <xsl:call-template name="get_parent">
                            <xsl:with-param name="ABOUT" select="./@xml:id"/>
                            <xsl:with-param name="PARENT" select="./../@xml:id"/>
                        </xsl:call-template>
                    </dct:source>
                </xsl:for-each>
                
                <xsl:for-each select="/tei:TEI//tei:body/@xml:id">
                    <dct:hasPart>
                        <xsl:value-of select="concat($DOC_PUB,.)"/>
                    </dct:hasPart>
                </xsl:for-each>
            </rdf:Description>
            
            <xsl:for-each select="//tei:sourceDesc//tei:list//tei:item">
                <xsl:call-template name="get_parent">
                    <xsl:with-param name="ABOUT" select="./@xml:id"/>
                    <xsl:with-param name="PARENT" select="./../@xml:id"/>
                </xsl:call-template>
            </xsl:for-each>

            <!-- add structural rdf for the head section -->
            <!-- creates relationship for title elements within the author tag -->
            <xsl:for-each select="//tei:author/tei:title">
                <xsl:if test="text() [normalize-space(.) ]">
                    <xsl:call-template name="get_parent">
                        <xsl:with-param name="ABOUT" select="./@xml:id"/>
                        <xsl:with-param name="PARENT" select="./../@xml:id"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:for-each>



            <!--  Simplified extraction.  The first stage locates all body elements, and creates RDF relationship to that element's immediate parent  -->
            <!-- Creation of RDF statements describing Text level divisions  -->
            <xsl:for-each select="/tei:TEI/tei:text//*">
                <xsl:call-template name="get_parent">
                    <xsl:with-param name="ABOUT" select="./@xml:id"/>
                    <xsl:with-param name="PARENT" select="./../@xml:id"/>
                </xsl:call-template>
            </xsl:for-each>

            <!-- establish relationships from paragraph elements back to body tag  -->
            <xsl:for-each select="//tei:body//tei:p | //tei:body//tei:div | //tei:author">
                <xsl:call-template name="get_parent">
                    <xsl:with-param name="ABOUT" select="./@xml:id"/>
                    <xsl:with-param name="PARENT" select="./../@xml:id"/>
                </xsl:call-template>

                <xsl:call-template name="get_child">
                    <xsl:with-param name="ABOUT" select="./@xml:id"/>
                    <xsl:with-param name="CHILD" select="./../@xml:id"/>
                </xsl:call-template>

            </xsl:for-each>
        </rdf:RDF>
    </xsl:template>

    <!-- retrieve relationships to parent objects -->

    <xsl:template name="get_parent">
        <xsl:param name="ABOUT"> </xsl:param>
        <xsl:param name="PARENT"> </xsl:param>
        <rdf:Description>
            <xsl:attribute name="rdf:about">
                <xsl:value-of select="concat($DOC_PUB,$ABOUT)"/>
            </xsl:attribute>
            <dct:isPartOf>
                <xsl:value-of select="concat($DOC_PUB,$PARENT)"/>
            </dct:isPartOf>
        </rdf:Description>
    </xsl:template>

    <xsl:template name="get_child">
        <xsl:param name="ABOUT"> </xsl:param>
        <xsl:param name="CHILD"> </xsl:param>
        <rdf:Description>
            <xsl:attribute name="rdf:about">
                <xsl:value-of select="concat($DOC_PUB,$ABOUT)"/>
            </xsl:attribute>
            <dct:isPartOf>
                <xsl:value-of select="concat($DOC_PUB,$CHILD)"/>
            </dct:isPartOf>
        </rdf:Description>
    </xsl:template>

</xsl:stylesheet>
