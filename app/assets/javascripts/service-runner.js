
let esRunning = null;
let esError = false;
let esComponent = null;

function runService(sender) {
  if (esRunning) return;
  esRunning = true;

  const form = $(sender).parents('tr').find('form');
  const control = $('#service-runner');

  setMessage('Connecting to server...');
  setProgress(0, true);
  control.slideDown();
  $('html, body').animate({
    scrollTop: control.offset().top
  }, 2000);

  esError = false;
  esComponent = submitEventSource(form, {
    message: function(data) {
      setProgress(data.percent, true);
      setMessage(data.message);
    },
    error: function(data) {
      console.error(data);
      setProgress(null, false);
      const backtrace = data.backtrace.map(line => document.htmlEscape(line)).join('<br>');
      setMessage(`Error: ${data.message}
                    <a href="#" onclick="$('#backtrace').toggle(); return false">(more)</a>
                    <div id='backtrace' style="display: none">${backtrace}<div>`);
      esError = true;
    },
    open: function() {
      setMessage('Retrieving information...');
    },
    closed: function() {
      serviceStopped();
    }
  })
}

function stopService() {
  if (esComponent && confirm('Are you sure you want to stop the service?')) {
    esComponent.close();
    serviceStopped();
    setProgress(null, false);
    setMessage('Cancelled');
  }
}

function serviceStopped() {
  if (!esError) {
    const control = $('#service-runner');
    control.delay(3000).slideUp();
  }
  esRunning = false;
  esComponent = null;
}

function setProgress(percent, valid) {
  const control = $('#service-runner #output-progress .progress-bar');
  if (Number.isInteger(percent)) {
    control
      .css({width: `${percent}%`})
      .attr('aria-valuenow', percent)
      .html(`${percent}%`);

    if (percent < 100) {
      control.addClass('progress-bar-animated');
      control.addClass('progress-bar-striped');
    } else {
      control.removeClass('progress-bar-animated');
      control.removeClass('progress-bar-striped');
    }
  }
  if (valid) {
    control.removeClass('bg-danger');
  } else {
    control.addClass('bg-danger');
  }
}

function setMessage(html) {
  const control = $('#service-runner #output-message');
  control.html(html);
}
