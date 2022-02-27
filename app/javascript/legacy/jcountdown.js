(function($) {
  $.fn.setCountdown = function(options) {
    const defaults = {
      targetDate: '2012-12-21',
      itemLabels: [ 'Days', 'Hours', 'Minutes', 'Seconds' ]
    };

    options = $.extend(defaults, options);

    this.assignHtml(options);
    this.updateCountdown(options);

    return this;
  }

  $.fn.assignHtml = function(options) {
    let itemClasses = [ 'jctdn-days', 'jctdn-hours', 'jctdn-mins', 'jctdn-secs' ];
    let html = '';

    for (let i = 0; i < itemClasses.length; i++) {
      html += '<span class="' + itemClasses[i] + '"><div></div><label>' +
        options.itemLabels[i] + '</label></span>';
    }

    this.html(html);
  }

  $.fn.updateCountdown = function(options) {
    const self = $(this);

    let now = new Date();
    let target = new Date(options.targetDate);
    let diff = Math.floor((target.valueOf() - now.valueOf()) / 1000);

    let secs;
    let mins;
    let hours;
    let days;

    if ( diff <= 0 ) {
      secs = 0;
      mins = 0;
      hours = 0;
      days = 0;

      if (self.data('timer') ) {
        clearTimeout(self.data('timer'));
      }
    } else {
      secs = diff % 60;
      mins = Math.floor(diff / 60) % 60;
      hours = Math.floor(diff / (60 * 60)) % 24;
      days = Math.floor(diff / (60 * 60 * 24));

      const timer = setTimeout(function() { self.updateCountdown(options) }, 1000)
      self.data('timer', timer);
    }

    self.find('span.jctdn-days div').html(days);
    self.find('span.jctdn-hours div').html(hours > 9 ? hours : '0' + hours);
    self.find('span.jctdn-mins div').html(mins > 9 ? mins : '0' + mins);
    self.find('span.jctdn-secs div').html(secs > 9 ? secs : '0' + secs);
  }
})(jQuery);
