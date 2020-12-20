$(document).on('turbolinks:load', function() {
    $(".checkbox-menu").on("change", "input[type='checkbox']", function(e) {
        $(this).closest("li").toggleClass("active", this.checked);

        const input = $(this);
        const table = $('.table-override');
        const dataTable = table.DataTable();

        const index = parseInt(input.val());
        const visible = input.is(':checked');
        dataTable.column(index).visible(visible);

        const id = $(table).attr('id');
        const value = $(input).parents('ul')
            .find('input:checked')
            .map((_, input) => parseInt($(input).val()))
            .toArray();

        LocalStorage.setObject(id, value);
    });

    $(document).on('click', '.allow-focus', function (e) {
        e.stopPropagation();
    });
})

window.checkboxMenu = function (defaultColumns) {
    const table = $('.table-override');
    const id = $(table).attr('id');
    const checkboxes = $(".checkbox-menu input[type='checkbox']");

    let value = LocalStorage.getObject(id);
    if (!value) value = defaultColumns;

    if (value) {
        $.each(checkboxes, function (_, checkbox) {
            const cb = $(checkbox);
            const checked = value.indexOf(parseInt(cb.val())) >= 0;
            cb.prop('checked', checked);
            cb.closest("li").toggleClass("active", checked);
        });
    } else {
        checkboxes.prop('checked', true);
    }
}
