<?xml version="1.0" encoding="utf-8"?>
<!--  incomplete xslt to extract rdf data from tei encoded text -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:dct="http://purl.org/dc/terms/"
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
                
                <xsl:for-each select="//tei:sourceDesc/tei:p">
                    <!-- this label is made up, replace with tag from schema -->
                    <dct:sourceDescription>
                        <xsl:value-of select="."/>
                    </dct:sourceDescription>
                </xsl:for-each> <dct:type>TEI/XML</dct:type>
                <dct:conformsTo>
                    <xsl:value-of select="$CONFORMATION"/>
                </dct:conformsTo>
                <xsl:for-each select="/tei:TEI//tei:body/@xml:id">
                    <dct:hasPart>
                        <xsl:value-of select="."/>
                    </dct:hasPart>
                </xsl:for-each>
            </rdf:Description>
            
            <!-- add structural rdf for the head section -->
            <!-- creates relationship for title elements within the author tag -->
            <xsl:for-each select="//tei:author/tei:title">
                <xsl:if test="text() [normalize-space(.) ]">       
                    <xsl:call-template name="get_parent">
                        <xsl:with-param name="ABOUT" select="./@xml:id"></xsl:with-param>
                        <xsl:with-param name="PARENT" select="./../@xml:id"></xsl:with-param>
                    </xsl:call-template>   
                </xsl:if>
            </xsl:for-each>
            
            <!--  create structural relationships for list elements within SourceDesc tag -->
            <xsl:for-each select="//tei:sourceDesc//tei:list">                              
                <xsl:call-template name="get_parent">
                    <xsl:with-param name="ABOUT" select="./@xml:id"></xsl:with-param>
                    <xsl:with-param name="PARENT" select="./../@xml:id"></xsl:with-param>
                </xsl:call-template>              
            </xsl:for-each> 
            
            <xsl:for-each select="//tei:sourceDesc//tei:list//tei:item">                              
                <xsl:call-template name="get_parent">
                    <xsl:with-param name="ABOUT" select="./@xml:id"></xsl:with-param>
                    <xsl:with-param name="PARENT" select="./../@xml:id"></xsl:with-param>
                </xsl:call-template>                  
            </xsl:for-each> 
                     
<!--  Simplified extraction.  The first stage locates all body elements, and creates RDF relationship to that element's immediate parent  -->
            <!-- Creation of RDF statements describing Text level divisions  -->
            <xsl:for-each select="/tei:TEI/tei:text//*">
                <xsl:call-template name="get_parent">
                    <xsl:with-param name="ABOUT" select="./@xml:id"></xsl:with-param>
                    <xsl:with-param name="PARENT" select="./../@xml:id"></xsl:with-param>
                </xsl:call-template>    
            </xsl:for-each> 
                       
<!-- establish relationships from paragraph elements back to body tag  -->
            <xsl:for-each select="//tei:body//tei:p | //tei:body//tei:div | //tei:author">
                <xsl:call-template name="get_parent">
                    <xsl:with-param name="ABOUT" select="./@xml:id"></xsl:with-param>
                    <xsl:with-param name="PARENT" select="./../@xml:id"></xsl:with-param>
                </xsl:call-template>    
                
                <xsl:call-template name="get_child">
                    <xsl:with-param name="ABOUT" select="./@xml:id"></xsl:with-param>
                    <xsl:with-param name="PARENT" select="./../@xml:id"></xsl:with-param>
                </xsl:call-template> 

            </xsl:for-each>
        </rdf:RDF>

    </xsl:template>
    
    <!-- retrieve relationships to parent objects -->
    
    <xsl:template name="get_parent">
        <xsl:param name="ABOUT" > 
        </xsl:param>
        <xsl:param name="PARENT" >
        </xsl:param>
        <rdf:Description>
            <xsl:attribute name="rdf:about">
                <xsl:value-of select="$ABOUT"/>
            </xsl:attribute>
            <dct:isPartOf>
                <xsl:value-of select="$PARENT"/>
            </dct:isPartOf>
        </rdf:Description>
        
        
        
    </xsl:template>
    
    <xsl:template name="get_child">
        <xsl:param name="ABOUT" > 
        </xsl:param>
        <xsl:param name="CHILD" >
        </xsl:param>
        <rdf:Description>
            <xsl:attribute name="rdf:about">
                <xsl:value-of select="$ABOUT"/>
            </xsl:attribute>
            <dct:isPartOf>
                <xsl:value-of select="$CHILD"/>
            </dct:isPartOf>
        </rdf:Description>
        
        
        
    </xsl:template>

</xsl:stylesheet>
