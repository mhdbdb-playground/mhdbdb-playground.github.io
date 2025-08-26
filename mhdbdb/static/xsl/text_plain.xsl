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
        <xsl:result-document href="#mhdbdb_text">
            <!-- Rendering of bootstrap modal -->
            <div class="card p-3">
                <div class="card-body">
                    <xsl:apply-templates></xsl:apply-templates>
                </div>
            </div>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="t:head">
        <h3 class="h4"><xsl:apply-templates></xsl:apply-templates></h3>
    </xsl:template>
    
    <xsl:template match="t:teiHeader"></xsl:template>
    
    <xsl:template match="t:body">
        <div><xsl:apply-templates></xsl:apply-templates></div>
    </xsl:template>
    
    <xsl:template match="t:hi">
        <span class="text-capitalize"><xsl:apply-templates></xsl:apply-templates></span>
    </xsl:template>
    
    <xsl:template match="t:w">
        <xsl:apply-templates></xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="t:seg">
        <xsl:apply-templates></xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="t:lb">
        <hr/>
        <xsl:value-of select="@n"/>
        <xsl:apply-templates></xsl:apply-templates>
        
    </xsl:template>
    
    <xsl:template match="t:p">
        <p><xsl:apply-templates></xsl:apply-templates></p>
    </xsl:template>
    
    <xsl:template match="t:l">
        <xsl:apply-templates></xsl:apply-templates><br/>
    </xsl:template>
    
</xsl:stylesheet>