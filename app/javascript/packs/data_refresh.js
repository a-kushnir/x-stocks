function refresh_status(text) {
    $('#data-refresh-text').html(text);
}

function update_prices() {
    const div_selector = $('#data-refresh-div');
    if (div_selector.length === 0) return;

    runEventSource('/services/run', {
        closed: function() {
            $('#data-refresh-spin').hide();
            refresh_status("Stocks updated");
            div_selector.fadeOut(3000, function() {
                div_selector.html('');
            });
        },
        error: function (data) {
            console.error(data);
            $('#data-refresh-spin').hide();
            refresh_status("Error: " + data.message);
        }
    })
}

document.addEventListener("turbolinks:load", update_prices);
$(document).ready(update_prices);
