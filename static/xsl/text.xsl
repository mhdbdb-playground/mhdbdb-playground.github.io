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
    
    <xsl:template match="/">
        <xsl:result-document href="#mhdbdb_text">
            <!-- Rendering of bootstrap modal -->
            <div class="modal fade" id="exampleModal" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h1 class="modal-title fs-5" id="exampleModalLabel">New message</h1>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body">
                            <ul>
                                <li>
                                    Wort-ID: <span id="modal_word_id"></span>
                                </li>
                                <li>
                                    Lemma: <a target="_blank" id="modal_lemma"></a>
                                </li>
                                <li>
                                    Bedeutung (MeaningRef): <a target="_blank" id="modal_meaningRef"></a>
                                </li>
                                <li>
                                    Type (WordRef): <a target="_blank" id="modal_wordRef"></a>
                                </li>
                                <li>
                                    Part of Speech (POS): <a target="_blank" id="modal_pos"></a>
                                </li>
                            </ul>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                        </div>
                    </div>
                </div>
            </div>
            
            
            
            <xsl:apply-templates></xsl:apply-templates>
            
            <script>
                const exampleModal = document.getElementById('exampleModal')
                if (exampleModal) {
                    exampleModal.addEventListener('show.bs.modal', event => {
                    
                        const mhdbdObjectsBaseURL = `${window.location.origin}/mhdbdb/objects`;
                    
                        // Element that triggered the modal
                        const wordElem = event.relatedTarget;
                        const wordId = wordElem.id;
                        // Extract info from data-bs-* attributes
                        const lemmaRef = wordElem.getAttribute('data-bs-lemmaref').split("#").pop();
                        const meaningRef = wordElem.getAttribute('data-bs-meaningref').split("#").pop();
                        const wordRef = wordElem.getAttribute('data-bs-wordref').split("#").pop();
                        const pos = wordElem.getAttribute('data-bs-pos');
                        // If necessary, you could initiate an Ajax request here
                        // and then do the updating in a callback.
                        
                        // Update the modal's content.
                        const modalTitle = exampleModal.querySelector('.modal-title');
                        const modalLemmaATag = exampleModal.querySelector('#modal_lemma');
                        const modalMeaningRefATag = exampleModal.querySelector('#modal_meaningRef');
                        const modalWordRefATag = exampleModal.querySelector('#modal_wordRef');
                        const modalPosATag = exampleModal.querySelector('#modal_pos');
                        const modalWordIdSpan = exampleModal.querySelector('#modal_word_id');
                        
                        modalTitle.textContent = `${wordElem.textContent} (${wordElem.getAttribute('id')})` 
                        
                        
                        
                        
                        modalLemmaATag.textContent = lemmaRef;
                        let lemmaRefUrl = new URL(window.location.href);
                        lemmaRefUrl.searchParams.set("mode", "text_analysis");
                        lemmaRefUrl.searchParams.set("anyRef", lemmaRef);
                        modalLemmaATag.setAttribute("href", lemmaRefUrl);
                        
                        modalMeaningRefATag.textContent = meaningRef;
                        let meaningRefUrl = new URL(window.location.href);
                        meaningRefUrl.searchParams.set("mode", "text_analysis");
                        meaningRefUrl.searchParams.set("anyRef", meaningRef);
                        modalMeaningRefATag.setAttribute("href", meaningRefUrl);
                        
                        modalWordRefATag.textContent = wordRef;
                        let wordRefURL = new URL(window.location.href);
                        wordRefURL.searchParams.set("mode", "text_analysis");
                        wordRefURL.searchParams.set("anyRef", wordRef);
                        modalWordRefATag.setAttribute("href", wordRefURL);
                        
                        modalPosATag.textContent = pos;
                        //modalPosATag.setAttribute("href", mhdbdObjectsBaseURL + pos);
                        
                        modalWordIdSpan.textContent = wordId;
                        
                    })
                }
                
            </script>
            
        </xsl:result-document>
    </xsl:template>
    
    <!--Handling TEI HEADER-->
    <xsl:template match="t:teiHeader">
        
    </xsl:template>
    
    
    <!--From here body-->
    <xsl:template match="t:body/t:div/t:head">
        
        <div class="bg-light p-3 mb-2">
            <xsl:apply-templates></xsl:apply-templates>
        </div>
        
        
    </xsl:template>
    
    <xsl:template match="t:p">
        <p class="bg-light mt-2 p-3"><xsl:apply-templates></xsl:apply-templates></p>
    </xsl:template>
    
    <xsl:template match="t:l">
        <div><small class="text-muted me-2"><xsl:value-of select="@n"/></small> <xsl:apply-templates></xsl:apply-templates></div>
    </xsl:template>
    
    <xsl:template match="t:w">
        <a 
            data-bs-toggle="modal" 
            data-bs-target="#exampleModal" 
            data-bs-lemmaref="{@lemmaRef}" 
            data-bs-meaningref="{@meaningRef}"
            data-bs-wordref="{@wordRef}"
            data-bs-pos="{@pos}"
            class="text-color-none text-decoration-none" 
            id="{@xml:id}" 
            href="{@lemmaRef}">
            <xsl:value-of select="."/>
        </a>
    </xsl:template>
    
    <xsl:template match="t:hi">
        <span class="text-capitalize"><xsl:apply-templates></xsl:apply-templates></span>
    </xsl:template>
    
    
    <xsl:template match="t:lb">
        <p class="border-top border-bottom-2 m-0 text-muted" data-n="{@n}"><small><xsl:value-of select="@n"/></small></p>
    </xsl:template>
    
    <xsl:template match="t:seg">
        <span id="{@xml:id}"><xsl:value-of select="."/></span>
    </xsl:template>

    <xsl:template match="t:pb">
        <p class="mt-5 mb-2">Seite: <xsl:value-of select="@n"/></p>
    </xsl:template>
    
    
</xsl:stylesheet>