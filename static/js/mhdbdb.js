
// ensuring that mhdbdb object is defined
if (typeof window.mhdbdb === 'undefined') {
    window.mhdbdb = {};
}


window.mhdbdb = (() => {

    /**
     * Fetches a gzipped JSON file and returns the parsed JSON data.
     * @param {string} url URL of the gzipped JSON file to be fetched.
     * @param {Function} callback Optional callback function to handle the parsed JSON data.
     * @returns {Promise<Object>} Parsed JSON data.
     */
    const fetchGzip = async (url, callback) => {
        let parsedJsonData;
        try {
            await fetch(url).then(async (response) => {
                // decompress the response from
                let ds = new DecompressionStream("gzip");
                let decompressedStream = response.body.pipeThrough(ds);
                let decompressed = await new Response(decompressedStream).blob();
                let jsonText = await decompressed.text();
                // parse the json text
                parsedJsonData = JSON.parse(jsonText);
            });
        } catch(error){
            const MSG = `Could not fetch project data from ${url}. Might also be a problem related to json parsing. Make sure that a valid json is available under the specified location. Got error: ${error}`;
            console.error(MSG);
        }
        
        if(callback){
            callback(parsedJsonData);
        }
        return parsedJsonData;
    }

    /**
     * Fetches a gzipped JSON file and returns the parsed JSON data.
     * @param {string} url URL of the gzipped JSON file to be fetched.
     * @param {Function} callback Optional callback function to handle the parsed XML data.
     * @returns {Promise<Object>} Parsed JSON data.
     */
    const fetchGzipXml = async (url, callback) => {
        let parsedXmlData;
        try {
            await fetch(url).then(async (response) => {
                // decompress the response from
                let ds = new DecompressionStream("gzip");
                let decompressedStream = response.body.pipeThrough(ds);
                let decompressed = await new Response(decompressedStream).blob();
                let xmlText = await decompressed.text();
                // parse the xml text
                parsedXmlData = new window.DOMParser().parseFromString(xmlText, "text/xml");
            });
        } catch(error){
            const MSG = `Could not fetch project data from ${url}. Might also be a problem related to xml parsing. Make sure that a valid xml is available under the specified location. Got error: ${error}`;
            console.error(MSG);
            console.error(error);
        } finally {
            if(callback){
                callback(parsedXmlData);
            }
        }

    }


    return {
        fetchGzip,
        fetchGzipXml
    };

})();