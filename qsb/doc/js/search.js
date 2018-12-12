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
    if (value == "") {
        resetSearch();
        return;
    }
    $(".docInvisibleContent").each(function(index) {
        var htmlString = $(this).html().toLowerCase();
        if (htmlString.includes(value.toLowerCase())) {
            $(this).parent().parent().show();
        }
    });
    $("#searchResultsContainer").show();
}

function resetSearch() {
    $("#searchResultsContainer").hide();
    $("#modulesContainer").children().hide();
    $("#pattern").val("");
}

function showAllSearch() {
    $("#searchResultsContainer").show();
    $("#modulesContainer").children().show(); 
}


