$( document ).ready(function() {
    resetSearch();

    $( "#search" ).on( "click", function() {
        commenceSearch();
    });

    $( "#reset" ).on( "click", function() {
        resetSearch();
    });

    console.log( "Documentation loaded!" );
});

function commenceSearch() {
    var value = $("#pattern").val();
    $("#modulesContainer").children().hide();
    if (value == "") {
        return;
    }
    var hits = 0;
    $(".docInvisibleContent").each(function(index) {
        var htmlString = $(this).html().toLowerCase();
        if (htmlString.includes(value.toLowerCase())) {
            $(this).parent().parent().show();
            hits = hits +1;
        }
    });
    $("#searchResultsContainer").show();
    if (hits == 0) {
        $("#notFound").show();
        console.log("Keine Suchergebnisse!");
    }
}

function resetSearch() {
    $("#searchResultsContainer").show();
    $("#modulesContainer").children().show();
    $("#pattern").val("");
    $("#notFound").hide();
}

function showAllSearch() {
    $("#searchResultsContainer").show();
    $("#modulesContainer").children().show(); 
}


