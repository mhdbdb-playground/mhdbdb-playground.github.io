

if (typeof window.mhdbdbBasket === 'undefined') {
    window.mhdbdbBasket = {};
}



window.mhdbdbBasket = (() => {

    // generate jsdoc of object type
    /**
     * @typedef {Object} WordObject
     * @property {string} word - The word itself.
     * @property {string} wordId - The unique identifier for the word.
     * @property {string} wordContext - The context in which the word is used.
     * @property {string} wordMeaningRef - A reference to the word's meaning.
     * @property {string} wordLemmaRef - A reference to the word's lemma.
     */

    /*
     * @type {WordObject}
     */
    const example = {
        word: "exampleWord",
        wordId: "exampleWordId",
        wordContext: "this is the context of the lemma",
        wordMeaningRef: "lemma_sense_1",
        wordLemmaRef: "lemma_1"

    }

    /**
     * Saves a word object to local storage.
     * @param {string} id 
     * @param {WordObject} wordObject 
     */
    const save = (id, wordObject) => {
        localStorage.setItem(id, JSON.stringify(wordObject));
    }

    const deleteById = (id) => {
        localStorage.removeItem(id);
    }

    const deleteAll = () => {
        localStorage.clear();
    }

    const findById = (id) => {
        return JSON.parse(localStorage.getItem(id));
    }

    /**
     * @returns {WordObject[]}
     */
    const findAll = () => {
        var values = [],
        keys = Object.keys(localStorage),
        i = keys.length;

        while ( i-- ) {
            values.push( 
                JSON.parse(localStorage.getItem(keys[i]))
            );
        }

        return values;
    }

    const existsById = (id) => {
        return localStorage.getItem(id) !== null;
    }

    return {
        save,
        deleteById,
        findById,
        findAll,
        deleteAll,
        existsById
    }

})();