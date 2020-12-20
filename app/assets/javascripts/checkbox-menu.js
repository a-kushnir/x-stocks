$(document).on('turbolinks:load', function() {
    $(".checkbox-menu").on("change", "input[type='checkbox']", function() {
        $(this).closest("li").toggleClass("active", this.checked);
    });

    $(document).on('click', '.allow-focus', function (e) {
        const input = $(e.target).children('input');
        const table = $('.table-override').DataTable();
        const index = parseInt(input.val());
        const visible = !input.is(':checked');
        table.column(index).visible(visible);
        e.stopPropagation();
    });
})
