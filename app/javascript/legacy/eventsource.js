
window.submitEventSource = function(form, options) {
    form = $(form);

    const url = form[0].action;
    let data = form.serializeArray();
    data = data.filter(item => item.name !== 'authenticity_token');

    options ||= {}
    options.data = data;

    return runEventSource(url, options);
}

window.runEventSource = function(url, options) {
    if (options.data) {
        const uri = new URL(url);
        options.data.forEach(function (param) {
            uri.searchParams.append(param.name, param.value);
        })
        url = uri.toString();
    }

    const source = new EventSource(url);
    source.addEventListener('message', function(e) {
        if (typeof(options.message) === 'function') {
            options.message(JSON.parse(e.data));
        }
    }, false);
    source.addEventListener('exception', function(e) {
        if (typeof(options.error) === 'function') {
            options.error(JSON.parse(e.data));
        }
    }, false);
    source.addEventListener('open', function(e) {
        // Connection was opened.
        if (typeof(options.open) === 'function') {
            options.open();
        }
    }, false);
    source.addEventListener('error', function(e) {
        source.close();
        if (typeof(options.closed) === 'function') {
            options.closed();
        }
    }, false);

    return source;
}
