export function urlFor(url, params) {
  const a = document.createElement('a');
  a.href = url;
  url = a.href;

  if (params) {
    const uri = new URL(url);
    for (const [key, value] of Object.entries(params)) {
      uri.searchParams.append(key, String(value));
    }
    return uri.toString();
  } else {
    return url;
  }
}

export function runEventSource(url, options) {
  url = urlFor(url, options.data);

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

export function submitEventSource(form, options) {
  const url = form.action;

  const data = Object.fromEntries(new FormData(form).entries());
  delete data['authenticity_token'];
  options ||= {}
  options.data = data;

  return runEventSource(url, options);
}
