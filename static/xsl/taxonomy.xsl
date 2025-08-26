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
    
    <xsl:param name="OBJECT_ID" as="xs:string"/>
    <xsl:param name="PROJECT_ABBR" as="xs:string"/>
    <xsl:param name="OBJECT_TYPE" as="xs:string"/>
    <xsl:param name="GAMS_API_ORIGIN" as="xs:string"></xsl:param>
    
    <xsl:param name="FRONTEND_ORIGIN" as="xs:string"/>
    <xsl:param name="FRONTEND_PATHNAME" as="xs:string"/>
    <xsl:param name="FRONTEND_MODE"/>
    
    

    <xsl:template match="/">
        <xsl:result-document href="#mhdbdb_tei_list">
            <xsl:choose>
                <xsl:when test="$OBJECT_ID = 'mhdbdb.persons'">
                    <xsl:apply-templates mode="PERSONS"></xsl:apply-templates>
                </xsl:when>
                <xsl:when test="$OBJECT_ID = 'mhdbdb.lexicon'">
                    <xsl:call-template name="renderLexicon"></xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates mode="TAXONOMY"></xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
            
        </xsl:result-document>
    </xsl:template>
    
    
    
    <xsl:template name="renderLexicon">
        <p>Renders a limited list of list items via XSLT</p>
        <ul class="list-group">
            <xsl:for-each select="//t:body/t:div/t:entry[position()&lt;11]">
                <li class="list-group-item">
                    <xsl:value-of select="@xml:id"/>
                </li>
            </xsl:for-each>
        </ul>
        
    </xsl:template>

    
    <!--***
        Templates rendering the taxonomies
    *** -->
    
    <xsl:template match="t:fileDesc" mode="TAXONOMY"></xsl:template>
    <xsl:template match="t:body" mode="TAXONOMY"></xsl:template>
    
    <xsl:template match="t:taxonomy" mode="TAXONOMY">
        <h2 class="h4"><xsl:value-of select="t:desc"/></h2>
        <ul class="list-group">
            <xsl:apply-templates mode="TAXONOMY" select="t:category"></xsl:apply-templates>
        </ul>
    </xsl:template>
    
    <xsl:template match="t:category" mode="TAXONOMY">
        <li class="list-group-item" id="{@xml:id}">
            <xsl:value-of select="t:catDesc/t:term[@xml:lang = 'de']"/> - 
            <small><xsl:value-of select="t:catDesc/t:term[@xml:lang = 'en']"/></small>
            <ul>
                <xsl:for-each select="t:catDesc/t:ptr">
                    <li>
                        <a href="{@target}"><xsl:value-of select="@type"/></a>    
                    </li>
                </xsl:for-each>
            </ul>
        </li>
    </xsl:template>
    
    <!--***
        Templates rendering the person register
    *** -->
    <xsl:template match="t:teiHeader" mode="PERSONS">
        <h2 class="h5"><xsl:value-of select="t:fileDesc/t:titleStmt/t:title"/></h2>
    </xsl:template>
    <xsl:template match="t:listPerson" mode="PERSONS">
        <ul class="list-group">
            <xsl:apply-templates mode="PERSONS"></xsl:apply-templates>
        </ul>
    </xsl:template>
    <xsl:template match="t:person" mode="PERSONS">
        <li class="list-group-item" id="{@xml:id}">
            <xsl:value-of select="t:persName"/>
            <ul>
                <xsl:for-each select="t:idno">
                    <li><xsl:value-of select="@type"/>: <xsl:value-of select="."/></li>
                </xsl:for-each>
                
                <li><a target="_blank" href="/mhdbdb/objects/mhdbdb.works#{t:note}"><xsl:value-of select="t:note"/></a></li>
            </ul>
            
            
        </li>
    </xsl:template>
    <xsl:template match="t:listRelation" mode="PERSONS">
        <ul class="list-group">
            <xsl:apply-templates mode="PERSONS"></xsl:apply-templates>
        </ul>
    </xsl:template>
    <xsl:template mode="PERSONS" match="t:relation">
        <li class="list-group-item">
            <a href="{@active}"><xsl:value-of select="@active"/></a> - <xsl:value-of select="@name"/> - <a href="{@passive}"><xsl:value-of select="@passive"/></a>
        </li>
    </xsl:template>
    
    
    
</xsl:stylesheet>