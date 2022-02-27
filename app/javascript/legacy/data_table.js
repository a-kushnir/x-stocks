
document.addEventListener("turbolinks:load", () => {
    const options = {}

    const url = new URL(document.URL);
    options.search = {search: url.searchParams.get('search') || ''};

    const displayStart = parseInt(url.searchParams.get('from'));
    options.displayStart = !isNaN(displayStart) ? displayStart : 0;

    const pageLength = parseInt(url.searchParams.get('length'))
    options.pageLength = !isNaN(pageLength) ? pageLength : 10;

    let order =
        url.searchParams.get('order') !== null ?
        url.searchParams.get('order').split('-') : null;

    if (Array.isArray(order) && order.length === 2 &&
        !isNaN(order[0]) && (order[1] === 'asc' || order[1] === 'desc'))
        order[0] = parseInt(order[0]);
    else
        order = null;

    options.order = order;

    options.drawCallback = function() {
        const table = (this).DataTable();
        const from = table.page.info().start;
        const length = table.page.info().length;
        const search = table.search();

        let order = table.order() !== null ? table.order() : null;
        if (typeof order[0] === "object") order = order[0];

        const url = new URL(document.URL);

        url.searchParams.delete('search');
        if (search !== '') url.searchParams.set('search', search);

        url.searchParams.delete('from');
        if (from > 0) url.searchParams.set('from', from);

        url.searchParams.delete('length');
        if (length !== 10) url.searchParams.set('length', length);

        url.searchParams.delete('order');
        if (order !== null && order.length !== 0 && JSON.stringify(order) !== JSON.stringify($.fn.dataTable.defaults.defaultOrder))
            url.searchParams.set('order', order.join('-'));

        history.replaceState(history.state, document.title, url);
    }
    $.extend($.fn.dataTable.defaults, options);

    $.fn.dataTable.orderOrSaved = function (order) {
        $.fn.dataTable.defaults.defaultOrder = order.slice();
        let result = $.fn.dataTable.defaults.order;
        if (result === undefined || result === null || result.length === 0) result = order;
        return result;
    };
});

function loadColumns(selector, defaultColumns) {
    const table = $(selector);
    const row = table.find('tr:first');

    const size = row.children().length;
    if (size <= 0) return null;

    let value = LocalStorage.getObject(table.attr('id'));
    if (!value) value = defaultColumns;
    if (!value) return null;

    const result = [];
    for(let i = 0; i < size; i++) {
        let visible =
            value.indexOf(i) >= 0 ||
            $(".checkbox-menu input[value='" + i + "']").length === 0;
        result.push({'visible': visible});
    }
    return result;
}

window.dataTable = function(table, options = {}, defaultColumns = []) {
    table = $(table);
    if (table.length > 0 && !$.fn.dataTable.isDataTable(table)) {
        checkboxMenu(defaultColumns);
        options['order'] = $.fn.dataTable.orderOrSaved(options['order']);
        options['pageLength'] = $.fn.dataTable.defaults.pageLength;
        options['columns'] = loadColumns(table, defaultColumns);
        options['dom'] = "<'row'<'col-12'<'float-left'f><'float-right'l>>><'row overflow-x-auto'<'col-sm-12'tr>><'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7'p>>"

        table.dataTable(options);
    }
}
