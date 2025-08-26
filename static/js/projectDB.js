
// ensuring that gams object is defined
if (typeof window.gams === 'undefined') {
    window.gams = {};
}


window.gams.projectDB = ((() => {

    /**
     * Reference to the dexie database
     */
    let _DB;

    /**
     * Schema declaration for the dexie database (mhdbdb_lemmata table)
     */
    const DEXIE_DB_SCHEME = {
        metadata: `
            key,
            value
        `,
        mhdbdb_lemmata: `
            id,
            texts_ss*,
            label_s*
        `,
        mhdbdb_senses: `
            id,
            lemma_s*
        `,
        mhdbdb_concepts: `
            id,
            label_ss,
            lemmata_ss,
            senses_ss
        `
    };

    /**
     * Setup the project database. Returns an event when the database is ready (and populated with data).
     * https://stackoverflow.com/questions/74997548/does-js-support-multi-threading-now
     * @param {string} projectAbbr Project abbreviation for GAMS5
     * @param {string} expirationDate
     *  Decides if the database should be repopulated (if lower than current date)
     * @param {number} version Allows to set a database version (defaults to 1)
     */
    const populateDatabase = (projectAbbr, version = 1) => {


        


        // This function will be passed into the worker
        const fillDatabase = (message) => {

            // first add method to fetch gzipped JSON data

            /**
             * Fetches a gzipped JSON file and returns the parsed JSON data.
             * @param {*} url URL of the gzipped JSON file to be fetched.
             * @returns {Promise<Object>} Parsed JSON data.
             */
            const fetchGzip = async (url) => {
                let parsedJsonData;
                try {
                    await (async () => {
                        await fetch(url).then(async (response) => {
                            // decompress the response from
                            let ds = new DecompressionStream("gzip");
                            let decompressedStream = response.body.pipeThrough(ds);
                            let decompressed = await new Response(decompressedStream).blob();
                            let jsonText = await decompressed.text();
                            // parse the json text
                            parsedJsonData = JSON.parse(jsonText);
                        });
                    })();
                } catch(error){
                    const MSG = `Could not fetch project data from ${url}. Might also be a problem related to json parsing. Make sure that a valid json is available under the specified location. Got error: ${error}`;
                    console.error(MSG);
                }
                
                return parsedJsonData;
            }

            // import dexie js
            importScripts('https://cdn.jsdelivr.net/npm/dexie@3.0.3/dist/dexie.min.js');

            const data = message.data;
        
            // ensures availability in the async functionbelow
            let projectAbbr = message.data.projectAbbr;
            const ORIGIN = message.data.origin;

            (async () => {

                // init dexie db
                let dexieDb = new Dexie(projectAbbr + "_db");
                const DB_SCHEME = message.data.DEXIE_DB_SCHEME;
                const VERSION = message.data.version;
                dexieDb.version(VERSION).stores(DB_SCHEME);

                // fetch datastream contents and load onto indexedDB
                let lexiconFiles = ["concept_index.gz","lemma_index.gz","senses_index.gz"];
                for (let file of lexiconFiles) {
                    let curTableName = `mhdbdb_`;
                    if(file.includes("lemma")) {
                        curTableName += "lemmata";
                    } else if(file.includes("senses")) {
                        curTableName += "senses";
                    } else if(file.includes("concept")) {
                        curTableName += "concepts";
                    }

                    let projectJsonLocation = `${ORIGIN}/mhdbdb/data/${file}`;

                    let dbData = await fetchGzip(projectJsonLocation);

                    await dexieDb[curTableName].bulkPut(dbData);
                }
                
                console.log("Database populated successfully at ", performance.now(), " ms");
                // TODO write creation date here instead??
                await dexieDb.metadata.put({key: 'createdAt', value: new Date().toUTCString() });
                // Response
                postMessage(data);
            })();            
        }

        // Dynamic creation of a worker
        const bytes = new TextEncoder().encode(`self.onmessage = ${fillDatabase.toString()}`)
        const blob = new Blob([bytes], {type: 'application/javascript'})
        const url = URL.createObjectURL(blob)
        const worker = new Worker(url)

        // arguments to be passed to the worker
        // (web workers do not have access to the window object)
        let workerArgs = {
            projectAbbr: projectAbbr, 
            version: version, 
            DEXIE_DB_SCHEME: DEXIE_DB_SCHEME, 
            origin: window.location.origin
        };

        // This message will be passed to the 
        worker.postMessage(workerArgs)

        // This function will be called when the worker finishes
        worker.onmessage = () => {
            // fire custom event when db is ready
            const DB_READY_EVENT = new CustomEvent("PROJECTDB_READY");
            document.dispatchEvent(DB_READY_EVENT);
        }


    }


    /**
     * Initializes and (if empty) populates the database with data from the provided project.
     * Allows to expire the database and rebuild it from scratch via defining an expiration date.
     * @param {string} projectAbbr abbreviation of the GAMS project.
     * @param {Date | string | number} expirationDate until which date the database is valid (if the database was created 2023 and given expiration date is 2024, it is still valid)
     *  If lower than the current date -> rebuild the database from srcatch.
     * @param {number} version Version number of the dexie database.
     */
    const initDB = (projectAbbr, expirationDate = new Date("1900"), version = 1) => {

        // make sure that expirationDate
        //  is a date object
        if (expirationDate instanceof Date === false) {
            expirationDate = new Date(expirationDate);
        }

        (async (projectAbbr) => {

            // Create or connect to the database
            let dexieDb = new Dexie(projectAbbr + "_db");
            setDB(dexieDb);
            dexieDb.version(version).stores(DEXIE_DB_SCHEME);

            // retrieve created at (will be written when database was filled)
            let indexedDBCreatedAtObject = await getDB().metadata.get('createdAt');

            if(!indexedDBCreatedAtObject) {
                console.log("No indexedDB createdAt found. ProjectDB is empty, populating it with data from GAMS5");
                populateDatabase(projectAbbr, version);
                return; 
            } 

            let indexedDBCreatedAt = new Date(indexedDBCreatedAtObject.value);

            // compare dates (creation date with incoming expirationDate date from GAMS5)
            if (new Date(indexedDBCreatedAt) > expirationDate) {
                console.log(`Detected up-to-date indexedDB (DB created at: ${indexedDBCreatedAt}, expiration date: ${expirationDate}). No need to repopulate the database.`);
                const DB_READY_EVENT = new CustomEvent("PROJECTDB_READY");
                document.dispatchEvent(DB_READY_EVENT);
                return;
            } else {
                console.log(`Detected outdated indexedDB (Given expirationDate date ${expirationDate} is newer than database createdAt ${indexedDBCreatedAt}). Deleting existing database and start reinitializing of ...`);
                getDB().delete();
                return initDB(projectAbbr, expirationDate, version);
            }

        // passing of argument ensures that project is defined in inner scope
        })(projectAbbr);
    };


    /**
     * Quick fulltext search allowing follow up actions on each result entry via callback function.
     * Does not wait for the complete database result -> allows dynamic ("on-found") update of display.
     * @param {string} searchString 
     * @param {function} callback What to do with a singular result entry.
     */
    const lemmaFulltextSearch = (searchString, callback) => {

        if (searchString.length < 1) {
            let msg = "Search string must be at least 1 character long";
            console.error(msg);
            throw new RangeError(msg);
        } 

        // async function could be used to await
        (async () => {
            resultObjects = getDB().mhdbdb_lemmata
                .where("label_s")
                //.startsWithIgnoreCase(searchString)
                .anyOfIgnoreCase(searchString)
                .each(callback);
        })();

    }

    
    /**
     * Returns the object(s) with the provided id
     * @param {string} id id of object to be found
     * @param {function} callback function to be called with the result object(s)
     * @returns {Array<Object>} object(s) with the provided id
     */
    const idSearch = (id, callback = null) => {
        (async () => {
            resultObjects = await getDB().mhdbdb_lemmata
                .where("id")
                .anyOfIgnoreCase(id)
                // TODO seems like an exepnsive operation!
                .toArray();    

            // Emit custom event
            const event = new CustomEvent("projectDB_idsearch_hit", { detail: resultObjects });
            document.dispatchEvent(event);

            // if provided, call the callback function
            if(callback)
                callback(resultObjects);
            
        })();
    }

    /**
     * Finds a lemma by its ID.
     * @param {string} id - The ID of the lemma to find.
     * @param {function} callback - Function to call with the found lemma.
     */
    const findLemmaById = (id, callback) => {
        (async () => {
            let result = await getDB().mhdbdb_lemmata
                .where("id")
                .equals(id)
                .first();

            if (callback) callback(result);
        })();
    }

    /**
     * Finds a sense by its ID.
     * @param {string} id - The ID of the sense to find.
     * @param {function} callback - Function to call with the found sense.
     */
    const findConceptLabelBySenseId = (id, callback) => {
        (async () => {
            let result = await getDB().mhdbdb_senses
                .where("id")
                .equals(id)
                .first();

            let conceptIds = result.concepts_ss;
            let foundConcepts = await getDB().mhdbdb_concepts
                .where("id")
                .anyOfIgnoreCase(Array.from(conceptIds))
                .toArray();
            let conceptLabel = foundConcepts.map(concept => concept.labels_ss[0]).join(" &middot; ");
            if (callback) callback(conceptLabel);
        })();
    }

    /**
     * Returns the object(s) with the provided id
     * @param {Array<string>} types dc types to be found
     * @param {function} callback function to be called with the result object(s)
     * @returns {Array<Object>} object(s) with the provided id
     * 
     */
    const typeSearch = (types, callback) => {
        (async () => {
            getDB().mhdbdb_lemmata
                .where("type_s")
                .anyOfIgnoreCase(types)
                .each(callback);
        })();
    }


    /**
     * 
     * @param {Array<string>} textIds 
     * @param {function} callback 
     */
    const lemmaTextsSearch = (textIds, callback) => {
        console.log("lemmaTextsSearch called with textIds: ", textIds);
        (async () => {
            getDB().mhdbdb_lemmata
                .where("texts_ss")
                .anyOfIgnoreCase(textIds)
                .each(callback);

            console.log("lemmaTextsSearch finished");
        })();
    }


    /**
     * Finds all senses for a given lemma ID with resolved concepts with labels.
     * This is a more complex query that resolves the concepts for each sense.
     * @param {*} lemmaId  
     * @param {*} callback 
     */
    const findAllSensesByLemmaId = (lemmaId, callback) => {
        (async () => {
            let foundSenses = await getDB().mhdbdb_senses
                .where("lemma_s")
                .equals(lemmaId)
                .toArray();

            let conceptIds = new Set();

            foundSenses.forEach((sense) => {
                if (sense.concepts_ss) {
                    sense.concepts_ss.forEach((conceptId) => {
                        conceptIds.add(conceptId);
                    });
                }
            });

            let conceptsResolved = await getDB().mhdbdb_concepts
                .where("id")
                .anyOfIgnoreCase(Array.from(conceptIds))
                .toArray();

            // add resolved concepts to each sense
            let conceptsSenseMap = new Map();
            conceptsResolved.forEach((concept) => {
                conceptsSenseMap.set(concept.id, concept);
            });

            let resultObject = {
                senses: foundSenses,
                conceptsSenseMap
            };

            if (callback) callback(resultObject);

        })();
    }

    /**
     * 
     * Finds all lemmata in the database and constructs a Map with the results.
     * @param {function} callback performed on the complete result set
     * @param {string} startsWithLabel optional search string to filter results by label
     * @param {Object} pagination pagination object with offset and limit properties
     * @param {boolean} includeCount if true, the result will also include the total count of results. This will slow down the search.
     * @returns 
     */
    const findAllLemmataAwait = (
        callback, 
        startsWithLabel = "", 
        pagination = {offset: 0, limit: 10},
        includeCount = false
    ) => {

        const foundLemma = new Map();
        let resultCount = null;

        (async() => {
            // start timer
            let startTime = performance.now();
            console.log("findAllLemmataAwait called at ", startTime, " ms");
            await getDB().mhdbdb_lemmata
                .where("label_s")
                .startsWith(startsWithLabel)
                .offset(pagination.offset)
                .limit(pagination.limit)
                .each((entry) => {
                    foundLemma.set(entry.id, entry);
                });

            if(includeCount) {
                resultCount = await getDB().mhdbdb_lemmata
                .where("label_s")
                .startsWith(startsWithLabel)
                .count()
            }

            let searchResult = {
                result: foundLemma, 
                resultCount,
                pagination,
                startsWithLabel
            }

            

            // end timer
            let endTime = performance.now();
            console.log(`findAllLemmataAwait: finished at `, endTime, " ms");

            // if provided, call the callback function
            if(callback)
                callback(searchResult);

            // // Emit custom event
            // const event = new CustomEvent("projectDB_findAllLemmata", { detail: resultObjects });
            // document.dispatchEvent(event);

        })();

    }


    /**
     * Finds a concept by its id and calls the callback function with the result. 
     * @param {string} conceptId id of the concept to be found
     * @param {function} callback called on the result object 
     */
    const findConceptById = (conceptId, callback) => {
        let startTime = performance.now();
        console.log("findConceptById called at ", startTime, " ms");
        (async () => {
            let result = await getDB().mhdbdb_concepts
                .where("id")
                .equals(conceptId)
                .first();

            let lemmaIds = result.lemmata_ss;

            // additionally resolve lemma labels
            let resultLemmata = await getDB().mhdbdb_lemmata
                .where("id")
                .anyOfIgnoreCase(lemmaIds)
                .toArray();

            // add to the result object (have the same order as the ids)
            result.lemmata = resultLemmata;

            if (callback) callback(result);

            let endTime = performance.now();
            console.log("findConceptById finished at ", endTime, " ms");
        })();
    }

    /**
     * 
     * Finds all lemmata in the database.
     * @param {function} callback performed on the complete result set
     * @param {string} conceptId concept id to match lemmata against
     * @param {Object} pagination pagination object with offset and limit properties
     * @param {boolean} includeCount if true, the result will also include the total count of results. This will slow down the search.
     * @returns 
     */
    const findAllLemmataByConceptIdAwait = (
        callback, 
        conceptId, 
        pagination = {offset: 0, limit: 10},
        includeCount = false
    ) => {

        const foundLemma = new Map();
        let resultCount = null;

        (async() => {
            // start timer
            let startTime = performance.now();
            console.log("findAllLemmataByConceptAwait called at ", startTime, " ms");
            await getDB().mhdbdb_lemmata
                .where("concepts_ss")
                .anyOfIgnoreCase(conceptId)
                .offset(pagination.offset)
                .limit(pagination.limit)
                .each((entry) => {
                    foundLemma.set(entry.id, entry);
                });

            if(includeCount) {
                resultCount = await getDB().mhdbdb_lemmata
                .where("concepts_ss")
                .anyOfIgnoreCase(conceptId)
                .count()
            }

            let searchResult = {
                result: foundLemma, 
                resultCount,
                pagination,
                conceptId
            }

            

            // end timer
            let endTime = performance.now();
            console.log(`findAllLemmataByConceptAwait: finished at `, endTime, " ms");

            // if provided, call the callback function
            if(callback)
                callback(searchResult);

        })();

    }


    /**
     * Finds all lemmata in the database.
     * @param {*} callback performed on each result entry
     * @param {string} startsWithLabel optional search string to filter results by label
     * @param {Object} pagination pagination object with offset and limit properties
     * 
     */
    const findAllLemmata = (callback, startsWithLabel = "", pagination = {offset: 0, limit: 10}) => {

        (async () => {
            getDB().mhdbdb_lemmata
                // the where will also sort the results
                .where("label_s")
                .startsWithIgnoreCase(startsWithLabel)
                .offset(2)
                .limit(10)
                .each(callback);
        })();

    }

    /**
     * Searches for lemmata based on their part of speech (pos). 
     * @param {Array<string>} posTags 
     * @param {*} callback 
     */
    const posSearch = (posTags, callback) => {
        (async () => {
            getDB().mhdbdb_lemmata
                .where("pos_ss")
                .anyOfIgnoreCase(posTags)
                .each(callback);
        })();
    }

    const getDB = () => {
        return _DB;
    }

    const setDB = (db) => {
        _DB = db;
    }

    return {
        typeSearch,
        initDB,
        idSearch,
        lemmaFulltextSearch,
        posSearch,
        lemmaTextsSearch,
        findAllLemmata,
        findAllLemmataAwait,
        findAllLemmataByConceptIdAwait,
        findConceptById,
        findAllSensesByLemmaId,
        findLemmaById,
        findConceptLabelBySenseId
    };

}))();

// Expose the db object
// window.gams.projectDB = projectDB;