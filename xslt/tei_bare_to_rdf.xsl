<?xml version="1.0" encoding="utf-8"?>
<!--  xslt to extract rdf data from TEI-Bare encoded text 
      TEI-Bare is a minimal TEI tagset, i.e. the very basic tags necessary
      to encode a document in TEI
      The TEI-Bare schema can be obtained from http://www.tei-c.org/
      
      This sheet also retrieves and converts into RDF/XML syntax any <relation> 
      elements, which are not part of TEI-Bare syntax but which can be used 
      within TEI to mark up RDF triples
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:dct="http://purl.org/dc/terms/"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xml="http://www.w3.org/XML/1998/namespace"
    xmlns:saws="http://www.purl.org/saws/ontology#">
    <!-- **** Add your own project-specific namespace declarations above, 
         as we have done with the saws example -->

    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

    <!-- Create variables to store the manuscript ID -->
    <xsl:variable name="TEI_ID" select="/tei:TEI/@xml:id"/>
    <xsl:variable name="MAN_ID" select="concat('http://www.ancientwisdoms.ac.uk/mss/',$TEI_ID)"/>
    <!-- **** Insert your own project-specific ID formats here for MAN_ID, 
        as we have done with the ancientwisdoms.ac.uk example-->

    <!-- Create a variable to store the namespace of the TEI node -->
    <!-- Thanks to Alohci at http://stackoverflow.com/questions/1319138/finding-xmlns-with-xsl-xpath -->
    <xsl:variable name="CONFORMATION" select="/tei:TEI/namespace::node()"/>

    <!-- Set up output document's root element. 
         Declare namespaces for rdf and for Dublin Core terms. -->

    <xsl:template match="/">
        <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
            xmlns:dct="http://purl.org/dc/terms/">

            <!-- Creation of RDF statements describing the document as a whole  -->

            <rdf:Description>
                <xsl:attribute name="rdf:about">
                    <xsl:value-of select="$MAN_ID"/>
                </xsl:attribute>
                <rdfs:label>
                    <xsl:value-of select="$TEI_ID"/>
                </rdfs:label>

                <!-- The document title: type = String Literal -->
                <xsl:for-each select="/tei:fileDesc/tei:titleStmt//tei:title">
                    <dct:title>
                        <xsl:value-of select="."/>
                        <rdfs:label>
                            <xsl:value-of select="."/>
                        </rdfs:label>
                    </dct:title>
                </xsl:for-each>

                <!-- The document author(s): type = String Literal (for now!) -->
                <xsl:for-each select="//tei:author">
                    <xsl:if test="text() [normalize-space(.) ]">
                        <dct:creator>
                            <rdf:type rdf:resource="http://purl.org/saws/ontology#Person"/>
                            <rdfs:label>
                                <xsl:value-of select="text()"/>
                            </rdfs:label>
                        </dct:creator>
                    </xsl:if>
                </xsl:for-each>

                <!-- The publishers of the document: String Literal (for now!) -->
                <xsl:for-each select="//tei:publicationStmt/tei:p">
                    <dct:publisher>
                        <xsl:value-of select="."/>
                        <rdfs:label>
                            <xsl:value-of select="."/>
                        </rdfs:label>
                    </dct:publisher>
                </xsl:for-each>

                <!-- Sources for the document: type = String Literal (description)-->
                <xsl:for-each select="//tei:sourceDesc/tei:p">
                    <dct:source>
                        <xsl:value-of select="."/>
                        <rdfs:label>
                            <xsl:value-of select="."/>
                        </rdfs:label>
                    </dct:source>
                </xsl:for-each>

                <!-- The type of the document: type = String Literal ("TEI/XML")-->
                <dct:type>TEI/XML</dct:type>

                <!-- TEI Schema declaration: type = Reference -->
                <dct:conformsTo>
                    <xsl:attribute name="rdf:resource">
                        <xsl:value-of select="$CONFORMATION"/>
                    </xsl:attribute>
                    <rdfs:label>
                        <xsl:value-of select="$CONFORMATION"/>
                    </rdfs:label>
                </dct:conformsTo>

                <!-- Structural links to parts of document: type = Reference -->
                <xsl:for-each select="/tei:TEI/tei:text/@xml:id">
                    <dct:hasPart>
                        <xsl:attribute name="rdf:resource">
                            <xsl:value-of select="$MAN_ID"/>
                        </xsl:attribute>
                    </dct:hasPart>
                </xsl:for-each>
            </rdf:Description>

            <!-- add structural rdf triples-->

            <!-- Create a node representing the <text> node(s) of the document -->
            <!-- NB Created hierarchical link saying that the text node(s) is a child part of
                the <TEI> document. No need to create links to the child nodes of <text> here
                as it is done later -->
            <xsl:for-each select="/tei:TEI/tei:text">
                <rdf:Description>
                    <xsl:attribute name="rdf:about">
                        <xsl:value-of select="concat($MAN_ID,'#',./@xml:id)"/>
                    </xsl:attribute>
                    <rdfs:label>
                        <xsl:value-of select="./@xml:id"/>
                    </rdfs:label>

                    <rdf:type rdf:resource="http://purl.org/saws/ontology#LinguisticObject"/>
                    <dct:isPartOf>
                        <xsl:attribute name="rdf:resource">
                            <xsl:value-of select="$MAN_ID"/>
                        </xsl:attribute>
                    </dct:isPartOf>
                </rdf:Description>
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
            </xsl:for-each>

        </rdf:RDF>
    </xsl:template>

    <!-- retrieve relationships to parent objects -->

    <xsl:template name="get_parent">
        <xsl:param name="ABOUT"> </xsl:param>
        <xsl:param name="PARENT"> </xsl:param>
        <rdf:Description>
            <xsl:attribute name="rdf:about">
                <xsl:value-of select="concat($MAN_ID,'#',$ABOUT)"/>
            </xsl:attribute>
            <rdfs:label>
                <xsl:value-of select="$ABOUT"/>
            </rdfs:label>

            <rdf:type rdf:resource="http://purl.org/saws/ontology#LinguisticObject"/>
            <dct:isPartOf>
                <xsl:attribute name="rdf:resource">
                    <xsl:value-of select="concat($MAN_ID,'#',$PARENT)"/>
                </xsl:attribute>
            </dct:isPartOf>
        </rdf:Description>


    </xsl:template>
    <!--
        <xsl:template name="get_child">
        <xsl:param name="ABOUT" > 
        </xsl:param>
        <xsl:param name="CHILD" >
        </xsl:param>
        <rdf:Description>
        <xsl:attribute name="rdf:resource">
        <xsl:value-of select="concat($MAN_ID,'#',$ABOUT)"/>
        </xsl:attribute>
        <rdf:type rdf:resource="http://purl.org/saws/ontology#LinguisticObject"/>
        <dct:isPartOf>
        <xsl:attribute name="rdf:resource">
        <xsl:value-of select="concat($MAN_ID,'#',$CHILD)"/>
        </xsl:attribute>                                 
        </dct:isPartOf>
        </rdf:Description>
        
        
        
        </xsl:template>
    -->


</xsl:stylesheet>
