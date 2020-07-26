function refresh_status(text) {
    $('#data-refresh-text').html(text);
}

function update_prices() {
    const div_selector = $('#data-refresh-div');
    if (div_selector.length === 0) return;

    $.ajax('/services/run', {method: 'post'})
        .done(function() {
            $('#data-refresh-spin').hide();
            refresh_status("Stocks updated");

            if (div_selector.data('refresh') &&
              typeof refresh_page === "function") {
                //refresh_page();
            }

            div_selector.fadeOut(3000, function() {
                div_selector.html('');
            });
        })
        .fail(function(jqXHR, textStatus, errorThrown) {
            $('#data-refresh-spin').hide();
            refresh_status("Error: " + errorThrown);
        });
}

document.addEventListener("turbolinks:load", update_prices);
$(document).ready(update_prices);
