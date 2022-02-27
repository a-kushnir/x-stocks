function refresh_stock_status(text) {
    $('#stock-update-text').html(text);
}

let updating_stock = false;
window.update_stock = function(stock_id) {
    if (updating_stock) return;
    updating_stock = true;

    $('#stock-update-button').prop('disabled', true);

    refresh_stock_status(`Updating... 0%`);

    runEventSource(`/services/stock_one/run?stock_id=${stock_id}`, {
        message: function(message) {
            refresh_stock_status(`Updating... ${message.percent}%`);
        },
        closed: function() {
            updating_stock = false;
            refresh_stock_status('Reloading...');
            location.reload();
        },
        error: function (data) {
            console.error(data);
            refresh_stock_status("Error: " + data.message);
        }
    })
}
