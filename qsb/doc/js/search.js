/**
 * Javascript der Index-Seite der Dokumentation von Symfonia.
 * 
 * @author totalwarANGEL
 * @version 1.1
 */

 /**
  * Event: Dokument geladen
  */
$(document).ready(function() {
    resetSearch();

    $("#search").on( "click", function() {
        commenceSearch();
    });

    $("#reset").on( "click", function() {
        resetSearch();
        $("#pattern").val("");
    });

    $("#searchForm").submit(function(event) {
        commenceSearch();
        return false;
    });

    console.log("Documentation loaded!");
});

var hitsMethod = 0;
var hitsBundles = 0;

/**
 * Die Suche nach Stichworten wird ausgeführt.
 */
function commenceSearch() {
    var value = $("#pattern").val();
    if (value === "") {
        return;
    }
    resetSearch();
    $("#indexEntriesContainer").hide();
    $("#searchResultsContainer").show();

    // Suche nach Stichwort
    $(".result").each(function(index) {
        var htmlString = $(this).html().toLowerCase();
        // Wenigstens 1 Wort des Patterns
        if (value.includes(",")) {
            if (containsAny(value.toLowerCase(), htmlString)) {
                showResult($(this));
            }
        }
        // Alle Worte des Patterns
        else if (value.includes("+")) {
            if (containsAll(value.toLowerCase(), htmlString)) {
                $(this).show();
                showResult($(this));
            }
        }
        // Einzelwort
        else {
            if (htmlString.includes(value.toLowerCase())) {
                $(this).show();
                showResult($(this));
            }
        }
    });

    if (hitsMethod == 0) {
        $("#directlinkContainer").hide();
    }
    if (hitsBundles == 0) {
        $("#bundlelinkContainer").hide();
    }
}

/**
 * Zält die Ergebnismengen hoch und macht das Element sichtbar.
 * @param {object} element jQuery object
 */
function showResult(element) {
    element.show();
    if (element.hasClass("method")) {
        hitsMethod += 1;
    }
    else if (element.hasClass("module")) {
        hitsBundles += 1;
    }
}

/**
 * Setzt die Elemente zurück, die durch die letzte Suche verändert wurden.
 */
function resetSearch() {
    hitsMethod = 0;
    hitsBundles = 0;

    $("#indexEntriesContainer").show();
    $("#searchResultsContainer").hide();
    $("#bundlelinkContainer").show();
    $("#directlinkContainer").show();
    $("div.result").hide();
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