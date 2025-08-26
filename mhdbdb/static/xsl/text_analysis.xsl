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
    <xsl:param name="ANY_REF"/>
    
    <xsl:template match="/">
        <xsl:result-document href="#mhdbdb_text">
            <xsl:variable name="wordReference">
                <xsl:value-of select="$ANY_REF"/>
            </xsl:variable>
            
            <xsl:variable name="wordReferenceType">
                <xsl:choose>
                    <xsl:when test="contains($ANY_REF,'_type_')">wordRef</xsl:when>
                    <xsl:when test="contains($ANY_REF,'_sense')">meaningRef</xsl:when>
                    <xsl:when test="contains($ANY_REF,'lemma')">lemmaRef</xsl:when>
                </xsl:choose>
            </xsl:variable>
            <div>
                <xsl:choose>
                    <xsl:when test="$wordReferenceType = 'wordRef'">
                        <h3>Wortvarianten</h3>
                        <small class="text-muted">(gleiche Wortvariante, verschiedenes Lemma)</small>
                    </xsl:when>
                    <xsl:when test="$wordReferenceType = 'lemmaRef'">
                        <h3>Wortstämme (Lemmata)</h3>
                        <small class="text-muted">(verschiedene Wortvariante, gleiches Lemma)</small>
                    </xsl:when>
                    <xsl:when test="$wordReferenceType = 'meaningRef'">
                        <h3>Wortbedeutungen</h3>
                        <small class="text-muted">(verschiedene Wortvariante, gleiches Lemma, gleiche Bedeutung)</small>
                    </xsl:when>
                    <xsl:otherwise>
                        <p>(Diese Ansicht funktioniert nur wenn über den Text angesteuert)</p>
                    </xsl:otherwise>
                </xsl:choose>
                <p><small class="text-muted">@<xsl:value-of select="$wordReferenceType"/>="<xsl:value-of select="$wordReference"/>"</small></p>
            </div>
            
            <ul class="list-group">
                <xsl:choose>
                    <xsl:when test="$wordReferenceType = 'lemmaRef'">
                        <xsl:for-each select="//t:w[@lemmaRef = concat('lexicon.xml#', $ANY_REF)]">
                            <li class="list-group-item mhdbdb_entity">
                                <h5 class="d-none"><xsl:value-of select="."/></h5>
                                <div class="form-check float-end">
                                    <input class="form-check-input mhdbdb_entity_btn" type="checkbox" value="" id="flexCheckDefault"/>
                                </div>
                                <button class="btn btn-outline-light text-dark btn-sm float-end me-2" type="button" data-bs-toggle="collapse" data-bs-target="#collapse_{@xml:id}" aria-expanded="false" aria-controls="collapse_{@xml:id}">
                                    ...
                                </button>
                                
                                <p class="mb-0">
                                    <xsl:text>...</xsl:text>
                                    <xsl:for-each select="preceding-sibling::t:w[position() &lt;= 10]">
                                        <xsl:sort select="count(preceding-sibling::t:w)" data-type="number" order="ascending"/>
                                        <xsl:value-of select="."/>
                                        <xsl:if test="position() != last()">
                                            <xsl:text> </xsl:text>
                                        </xsl:if>
                                    </xsl:for-each>
                                    
                                    <!-- Current word (highlighted) -->
                                    <xsl:text> </xsl:text><strong class="bg-warning"><xsl:value-of select="."/></strong><xsl:text> </xsl:text>
                                    <!-- 5 words after -->
                                    <xsl:for-each select="following-sibling::t:w[position() &lt;= 10]">
                                        <xsl:sort select="count(following-sibling::t:w)" data-type="number" order="descending"/>
                                        <xsl:value-of select="."/>
                                        <xsl:if test="position() != last()">
                                            <xsl:text> </xsl:text>
                                        </xsl:if>
                                    </xsl:for-each>
                                </p>
                                
                                
                                <ul class="collapse" id="collapse_{@xml:id}">
                                    <li>ID: <a href='/mhdbdb/objects/{$OBJECT_ID}#{@xml:id}' class="mhdbdb_word_id"><xsl:value-of select="@xml:id"/></a></li>
                                    <li>POS: <xsl:value-of select="@pos"/></li>
                                    <li>MeaningRef: <span class="mhdbdb_meaning_ref"><xsl:value-of select="@meaningRef"/></span></li>
                                    <li>wordRef: <xsl:value-of select="@wordRef"/></li>
                                    <li>lemmaRef: <a class="mhdbdb_lemma_ref" href='/mhdbdb/objects/{$OBJECT_ID}#{substring-after(@lemmaRef, "#")}'><xsl:value-of select="@lemmaRef"/></a></li>
                                </ul>
                                
                                
                                
                            </li>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="$wordReferenceType = 'wordRef'">
                        <xsl:for-each select="//t:w[@wordRef = concat('lexicon.xml#', $ANY_REF)]">
                            <li class="list-group-item mhdbdb_entity">
                                <h5 class="d-none"><xsl:value-of select="."/></h5>
                                <div class="form-check float-end">
                                    <input class="form-check-input mhdbdb_entity_btn" type="checkbox" value="" id="flexCheckDefault"/>
                                </div>
                                <button class="btn btn-outline-light text-dark btn-sm float-end me-2" type="button" data-bs-toggle="collapse" data-bs-target="#collapse_{@xml:id}" aria-expanded="false" aria-controls="collapse_{@xml:id}">
                                    ...
                                </button>
                                
                                <p>
                                    <xsl:text>...</xsl:text>
                                    <xsl:for-each select="preceding-sibling::t:w[position() &lt;= 10]">
                                        <xsl:sort select="position()" data-type="number" order="descending"/>
                                        <xsl:value-of select="."/>
                                        <xsl:if test="position() != last()">
                                            <xsl:text> </xsl:text>
                                        </xsl:if>
                                    </xsl:for-each>
                                    
                                    <!-- Current word (highlighted) -->
                                    <xsl:text> </xsl:text><strong class="bg-warning"><xsl:value-of select="."/></strong>
                                    <!-- 5 words after -->
                                    <xsl:for-each select="following-sibling::t:w[position() &lt;= 10]">
                                        <xsl:text> </xsl:text>
                                        <xsl:value-of select="."/>
                                    </xsl:for-each>
                                    <xsl:text>...</xsl:text>
                                </p>
                                
                                <ul class="collapse" id="collapse_{@xml:id}">
                                    <li>ID: <a href='/mhdbdb/objects/{$OBJECT_ID}#{@xml:id}' class="mhdbdb_word_id"><xsl:value-of select="@xml:id"/></a></li>
                                    <li>POS: <xsl:value-of select="@pos"/></li>
                                    <li>MeaningRef: <span class="mhdbdb_meaning_ref"><xsl:value-of select="@meaningRef"/></span></li>
                                    <li>wordRef: <xsl:value-of select="@wordRef"/></li>
                                    <li>lemmaRef: <a class="mhdbdb_lemma_ref" href='/mhdbdb/objects/{$OBJECT_ID}#{substring-after(@lemmaRef, "#")}'><xsl:value-of select="@lemmaRef"/></a></li>
                                </ul>
                            </li>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="$wordReferenceType = 'meaningRef'">
                        <xsl:for-each select="//t:w[@meaningRef = concat('lexicon.xml#', $ANY_REF)]">
                            <li class="list-group-item mhdbdb_entity">
                                <h5 class="d-none"><xsl:value-of select="."/></h5>
                                <div class="form-check float-end">
                                    <input class="form-check-input mhdbdb_entity_btn" type="checkbox" value="" id="flexCheckDefault"/>
                                </div>
                                <button class="btn btn-outline-light text-dark btn-sm float-end me-2" type="button" data-bs-toggle="collapse" data-bs-target="#collapse_{@xml:id}" aria-expanded="false" aria-controls="collapse_{@xml:id}">
                                    ...
                                </button>
                                
                                <p>
                                    <xsl:text>...</xsl:text>
                                    <xsl:for-each select="preceding-sibling::t:w[position() &lt;= 10]">
                                        <xsl:sort select="position()" data-type="number" order="descending"/>
                                        <xsl:value-of select="."/>
                                        <xsl:if test="position() != last()">
                                            <xsl:text> </xsl:text>
                                        </xsl:if>
                                    </xsl:for-each>
                                    
                                    <!-- Current word (highlighted) -->
                                    <xsl:text> </xsl:text><strong class="bg-warning"><xsl:value-of select="."/></strong>
                                    <!-- 5 words after -->
                                    <xsl:for-each select="following-sibling::t:w[position() &lt;= 10]">
                                        <xsl:text> </xsl:text>
                                        <xsl:value-of select="."/>
                                    </xsl:for-each>
                                    <xsl:text>...</xsl:text>
                                </p>
                                
                                <ul class="collapse" id="collapse_{@xml:id}">
                                    <li>ID: <a href='/mhdbdb/objects/{$OBJECT_ID}#{@xml:id}' class="mhdbdb_word_id"><xsl:value-of select="@xml:id"/></a></li>
                                    <li>POS: <xsl:value-of select="@pos"/></li>
                                    <li>MeaningRef: <span class="mhdbdb_meaning_ref"><xsl:value-of select="@meaningRef"/></span></li>
                                    <li>wordRef: <xsl:value-of select="@wordRef"/></li>
                                    <li>lemmaRef: <a class="mhdbdb_lemma_ref" href='/mhdbdb/objects/{$OBJECT_ID}#{substring-after(@lemmaRef, "#")}'><xsl:value-of select="@lemmaRef"/></a></li>
                                </ul>
                                
                            </li>
                        </xsl:for-each>
                    </xsl:when>
                </xsl:choose>
                
                
                <script>
                    document.querySelectorAll(".mhdbdb_entity_btn").forEach(storageSaveElem => {
                        
                        let containerLi = storageSaveElem.parentElement.parentElement;
                        
                        let wordId = containerLi.querySelector(".mhdbdb_word_id").textContent;
                        // mark checkboxes as checked when stored in basket
                        if(mhdbdbBasket.existsById(wordId)){
                            storageSaveElem.checked = true;
                        }
                        storageSaveElem.addEventListener("click", event => {
                            // delete from basket if getting unchecked
                            if(event.target.checked === false){
                                mhdbdbBasket.deleteById(wordId);
                                return;
                            }
                            
                            let word = containerLi.querySelector("h5").textContent;
                            let wordContext = containerLi.querySelector("p").textContent;
                            let wordMeaningRef = containerLi.querySelector(".mhdbdb_meaning_ref").textContent.replace("lexicon.xml#", "");
                            let wordLemmaRef = containerLi.querySelector(".mhdbdb_lemma_ref").textContent.replace("lexicon.xml#", "");
                            
                            let wordObject = {
                                word,
                                wordId,
                                wordContext,
                                wordMeaningRef,
                                wordLemmaRef
                            }
                            
                            mhdbdbBasket.save(wordId, wordObject);
                        });
                    
                    });
                </script>
                        
                
                
            </ul>
            
<!--            <xsl:apply-templates></xsl:apply-templates>-->
        </xsl:result-document>
    </xsl:template>
    
    
    
</xsl:stylesheet>