function refresh_status(text) {
    $('#data-refresh-text').html(text);
}

let updating_prices = false;
function update_prices() {
    if (updating_prices) return;
    updating_prices = true;

    const div_selector = $('#data-refresh-div');
    if (div_selector.length === 0) return;

    runEventSource('/services/run', {
        closed: function() {
            updating_prices = false;
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

document.addEventListener("turbo:load", update_prices);
$(document).ready(update_prices);
