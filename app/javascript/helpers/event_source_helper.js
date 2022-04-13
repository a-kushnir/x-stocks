export function urlFor(url, params) {
  const a = document.createElement('a');
  a.href = url;
  url = a.href;

  if (params) {
    const uri = new URL(url);
    params.forEach(function (param) {
      uri.searchParams.append(param.name, param.value);
    })
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
