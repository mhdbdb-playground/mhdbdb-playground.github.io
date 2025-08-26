<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:t="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:ixsl="http://saxonica.com/ns/interactiveXSLT"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:foaf="http://xmlns.com/foaf/0.1/"
    exclude-result-prefixes="xs math"
    version="3.0">
    
    
    <xsl:template match="/">
        <xsl:result-document href="#imprint">
            <xsl:apply-templates></xsl:apply-templates>
        </xsl:result-document>
    </xsl:template>
    
    
    <xsl:template match="t:head">
        <h3 class="h3 mt-4"><xsl:apply-templates></xsl:apply-templates></h3>
    </xsl:template>
    
    <xsl:template match="t:teiHeader">
        
    </xsl:template>
    
    <xsl:template match="t:p">
        <p><xsl:apply-templates></xsl:apply-templates></p>
    </xsl:template>
    
    <xsl:template match="t:ref">
        <a target="blank" href="{@target}"><xsl:apply-templates></xsl:apply-templates></a>
    </xsl:template>
    
</xsl:stylesheet>