//= require datatables
//= require eventsource

//= require bootstrap-select
$(document).on('turbolinks:load', function() {
    $(window).trigger('load.bs.select.data-api');

    $(function () {
      $('[data-toggle="tooltip"]').tooltip()
    })
});

function formatCurrency(total) {
    var neg = false;
    if(total < 0) {
        neg = true;
        total = Math.abs(total);
    }
    return (neg ? "-$" : '$') + parseFloat(total, 10).toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, "$1,").toString();
}
