$(document).on('turbo:load', function() {
  $(window).trigger('load.bs.select.data-api');

  $(function () {
    $('[data-toggle="tooltip"]').tooltip()
  })
  $(function () {
    $('[data-toggle="popover"]').popover({html: true})
  })

  $('[data-toggle="tooltip"]').tooltip()
});
