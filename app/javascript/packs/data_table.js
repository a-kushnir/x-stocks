
document.addEventListener("turbolinks:load", () => {
    const options = {}

    const url = new URL(document.URL);
    options.search = {search: url.searchParams.get('search') || ''};
    options.displayStart = url.searchParams.get('from') || 0;
    options.pageLength = url.searchParams.get('length') || 10;

    options.drawCallback = function() {
        const table = (this).DataTable();
        const from = table.page.info().start;
        const length = table.page.info().length;
        const search = table.search();

        const url = new URL(document.URL);
        url.searchParams.delete('search');
        if (search !== '') url.searchParams.set('search', search);
        url.searchParams.delete('from');
        if (from > 0) url.searchParams.set('from', from);
        url.searchParams.delete('length');
        if (length !== 10) url.searchParams.set('length', length);
        history.replaceState(history.state, document.title, url);
    }
    $.extend($.fn.dataTable.defaults, options);
});
