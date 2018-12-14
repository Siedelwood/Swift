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

    // Suche nach Stichwort
    var hits = 0;
    $(".docInvisibleContent").each(function(index) {
        var htmlString = $(this).html().toLowerCase();
        if (htmlString.includes(value.toLowerCase())) {
            $(this).parent().parent().show();
            hits = hits +1;
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