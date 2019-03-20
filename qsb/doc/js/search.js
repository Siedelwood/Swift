/**
 * Javascript der Index-Seite der Dokumentation von Symfonia.
 * 
 * @author totalwarANGEL
 * @version 1.0
 */

 /**
  * Event: Dokument geladen
  */
$(document).ready(function() {
    resetSearch();

    $( "#search" ).on( "click", function() {
        commenceSearch();
    });

    $( "#reset" ).on( "click", function() {
        resetSearch();
    });

    $("#searchForm").submit(function(event) {
        commenceSearch();
        return false;
    });

    console.log("Documentation loaded!");
});

/**
 * Die Suche nach Stichworten wird ausgeführt.
 */
function commenceSearch() {
    var value = $("#pattern").val();
    $("#modulesContainer").children().hide();
    if (value == "") {
        return;
    }
    $("#notFound").hide();

    // Suche nach Stichwort
    var hits = 0;
    $(".docInvisibleContent").each(function(index) {
        var htmlString = $(this).html().toLowerCase();
        // Wenigstens 1 Wort des Patterns
        if (value.includes(",")) {
            if (containsAny(value.toLowerCase(), htmlString)) {
                $(this).parent().parent().show();
                hits = hits +1;
            }
        }
        // Alle Worte des Patterns
        else if (value.includes("+")) {
            if (containsAll(value.toLowerCase(), htmlString)) {
                $(this).parent().parent().show();
                hits = hits +1;
            }
        }
        // Einzelwort
        else {
            if (htmlString.includes(value.toLowerCase())) {
                $(this).parent().parent().show();
                hits = hits +1;
            }
        }
    });

    // Zeige Resultate
    $("#searchResultsContainer").show();
    if (hits == 0) {
        $("#notFound").show();
    }
    console.log("Search had " + hits + " hits!");
}

/**
 * Setzt die Elemente zurück, die durch die letzte Suche verändert wurden.
 */
function resetSearch() {
    $("#searchResultsContainer").show();
    $("#modulesContainer").children().show();
    $("#pattern").val("");
    $("#notFound").hide();
}

/**
 * Checks, if the pattern is found in the string.
 * @param {string} pattern Words to find
 * @param {string} htmlString HTML string
 * @return {boolean} Pattern contained in string
 */
function containsAny(pattern, htmlString) {
    var patternArray = pattern.split(",");
    var patternFound = false;
    patternArray.forEach(function(element) {
        if (htmlString.includes(element)) {
            patternFound = true;
        }
    });
    return patternFound;
}

/**
 * Checks, if the pattern is found in the string.
 * @param {string} pattern Words to find
 * @param {string} htmlString HTML string
 * @return {boolean} Pattern contained in string
 */
function containsAll(pattern, htmlString) {
    var patternArray = pattern.split("+");
    var patternFound = true;
    patternArray.forEach(function(element) {
        if (!htmlString.includes(element)) {
            patternFound = false;
        }
    });
    return patternFound;
}