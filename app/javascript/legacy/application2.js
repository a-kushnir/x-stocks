//= require datatables
//= require eventsource.js
//= require checkbox-menu.js
//= require bootstrap-select
//= require local-store.js
//= require dateFormat.js
//= require jquery.dateFormat.js
//= require dataUnpack.js
//= require service-runner.js

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
