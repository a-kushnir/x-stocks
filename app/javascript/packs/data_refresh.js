function refresh_status(text) {
    $('#refresh-text').html(text);
}

$(document).ready(function() {
    if ($('#refresh-div').length === 0) return;

    $.ajax('/data/refresh', {method: 'post'})
        .done(function() {
            refresh_status("Refreshing page...");
            window.location.reload();
        })
        .fail(function(jqXHR, textStatus, errorThrown) {
            refresh_status("Error: " + errorThrown);
        });
    refresh_status("Updating prices...");
})
