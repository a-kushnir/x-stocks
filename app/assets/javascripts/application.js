//= require datatables
//= require eventsource
//= require checkbox-menu
//= require bootstrap-select
//= require local-store
//= require dateFormat
//= require jquery.dateFormat
//= require dataUnpack
//= require service-runner

$(document).on('turbolinks:load', function() {
    $(window).trigger('load.bs.select.data-api');

    $(function () {
      $('[data-toggle="tooltip"]').tooltip()
    })
    $(function () {
        $('[data-toggle="popover"]').popover({html: true})
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
