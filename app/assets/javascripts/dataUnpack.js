const FormatMethods = {
  currency: function (value) {
    if (value === null) return '';

    const formatter = new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
    });
    return formatter.format(value);
  },

  percentFixed: function(value, fractionDigits) {
    if (value === null) return '';

    return `${FormatMethods.numberFixed(value, fractionDigits)}%`;
  },

  numberFixed: function(value, fractionDigits) {
    if (value === null) return '';

    return Number(value).toLocaleString(undefined, {minimumFractionDigits: fractionDigits});
  },

  plusSign: function(value) {
    return value && value > 0 ? '+' : '';
  },

  deltaClass: function(value) {
    if (!value) {
      return 'text-muted';
    }
    else if (value < 0) {
      return 'text-danger';
    }
    else if (value > 0) {
      return 'text-success';
    }
  },

  recommendationHint: function(value) {
    if (value === null) return '';

    if (value <= 1.5) {
      return 'Str. Buy';
    } else if (value <= 2.5) {
      return 'Buy';
    } else if (value < 3.5) {
      return 'Hold';
    } else if (value < 4.5) {
      return 'Sell';
    } else {
      return 'Str. Sell';
    }
  },

  safetyHint: function(value) {
    if (value === null) return '';

    if (value >= 4.5) {
      return 'Very Safe';
    } else if (value >= 3.5) {
      return 'Safe';
    } else if (value >= 2.5) {
      return 'Borderline';
    } else if (value >= 1.5) {
      return 'Unsafe';
    } else {
      return 'Very Unsafe';
    }
  },

  metaScoreClass: function(value) {
    if (value === null) return '';

    if (value > 80) {
      return 'rec-str-buy';
    } else if (value > 60) {
      return 'rec-buy';
    } else if (value > 40) {
      return 'rec-hold';
    } else if (value > 20) {
      return 'rec-sell';
    } else {
      return 'rec-str-sell';
    }
  }
}

const Formats = {
  symbol: function(value) {
    const [symbol, logo, note] = value;

    let noteDiv = null;
    if (note) {
      noteDiv = $('<div>')
        .addClass('symbol-note')
        .addClass('alert')
        .addClass('alert-warning')
        .addClass('float-right')
        .append(
          $('<i>')
            .addClass('fas')
            .addClass('fa-thumbtack')
            .attr('data-toggle', 'tooltip')
            .attr('data-placement', 'right')
            .attr('title', note)
        )
    }

    return $('<td>')
      .addClass('text-nowrap')
      .addClass('border-right')
      .addClass('format-as-symbol')
      .attr('data-search', symbol)
      .attr('data-sort', symbol)

      .append(noteDiv)

      .append($('<div>')
        .addClass('symbol-logo')
        .addClass('text-center')
        .append($('<img>')
          .attr('src', logo ? logo : '/img/no-logo.png')
          .attr('alt', `${symbol} Logo`)
        )
      )

      .append($('<a>')
        .addClass(note ? 'has-note' : null)
        .attr('href', `/stocks/${symbol}`)
        .text(symbol)
      )
  },

  text: function(value) {
    return $('<td>')
      .addClass('text-nowrap')
      .text(value)
  },

  warn: function(value) {
    if (value === null) return $('<td>');

    return $('<td>')
      .attr('data-sort', 0)
      .append($('<strong>')
        .addClass('float-right')
        .addClass('text-danger')
        .text(value)
      );
  },

  currency: function (value) {
    return $('<td>')
      .attr('data-sort', value)
      .addClass('text-right')
      .text(FormatMethods.currency(value))
  },

  currencyOrWarn: function(value) {
    if (value === null) return $('<td>');
    return isNaN(value) ?
      Formats.warn(value) :
      Formats.currency(value);
  },

  currencyDelta: function(value) {
    return $('<td>')
      .addClass('text-right')
      .addClass(FormatMethods.deltaClass(value))
      .text(FormatMethods.plusSign(value) + FormatMethods.currency(value))
  },

  percent0: function(value) {
    return $('<td>')
      .addClass('text-right')
      .text(FormatMethods.percentFixed(value, 0))
  },

  percentDelta0: function(value) {
    return $('<td>')
      .addClass('text-right')
      .addClass(FormatMethods.deltaClass(value))
      .text(FormatMethods.plusSign(value) + FormatMethods.percentFixed(value, 0))
  },

  percent1: function(value) {
    return $('<td>')
      .addClass('text-right')
      .text(FormatMethods.percentFixed(value, 1))
  },

  percentDelta1: function(value) {
    return $('<td>')
      .addClass('text-right')
      .addClass(FormatMethods.deltaClass(value))
      .text(FormatMethods.plusSign(value) + FormatMethods.percentFixed(value, 1))
  },

  percent2: function(value) {
    return $('<td>')
      .attr('data-sort', value)
      .addClass('text-right')
      .text(FormatMethods.percentFixed(value, 2))
  },

  percentDelta2: function(value) {
    return $('<td>')
      .addClass('text-right')
      .addClass(FormatMethods.deltaClass(value))
      .text(FormatMethods.plusSign(value) + FormatMethods.percentFixed(value, 2))
  },

  percentOrWarn2: function(value) {
    if (value === null) return $('<td>');
    return isNaN(value) ?
      Formats.warn(value) :
      Formats.percent2(value);
  },

  recommendation: function(value) {
    if (value === null) return $('<td>');

    return $('<td>')
      .addClass('text-right')
      .attr('data-sort', value)
      .append($('<small>')
        .text(FormatMethods.recommendationHint(value))
      )
      .append(` ${FormatMethods.numberFixed(value, 2)}`);
  },

  safety: function(value) {
    if (value === null) return $('<td>');

    return $('<td>')
      .addClass('text-right')
      .attr('data-sort', value)
      .append($('<small>')
        .text(FormatMethods.safetyHint(value))
      )
      .append(' ')
      .append(` ${FormatMethods.numberFixed(value, 1)}`);
  },

  safetyAlt: function(value) {
    if (value === null) return $('<td>');

    const score = FormatMethods.numberFixed(value * 20, 0);
    return $('<td>')
      .addClass('text-center')
      .attr('data-sort', value)
      .append($('<span>')
        .addClass('badge')
        .addClass('badge-dark')
        .addClass(FormatMethods.metaScoreClass(score))
        .text(score)
      )
  },

  metaScore: function(value) {
    const [score, details] = value;
    if (score === null) return $('<td>');

    return $('<td>')
      .addClass('text-center')
      .attr('data-sort', score)
      .attr('data-toggle', 'tooltip')
      .attr('data-placement', 'left')
      .attr('title', details)
      .append($('<span>')
        .addClass('badge')
        .addClass('badge-dark')
        .addClass(FormatMethods.metaScoreClass(score))
        .text(score)
      );
  },

  date: function (value) {
    if (value === null) return $('<td>');

    value = new Date(`${value}T00:00:00`);
    return $('<td>')
      .addClass('text-right')
      .addClass('text-nowrap')
      .attr('data-sort', $.format.date(value, 'yyyy-MM-dd'))
      .text($.format.date(value, 'MMM, d yyyy'))
  },

  number: function (value) {
    return $('<td>')
      .addClass('text-right')
      .text(Number(value).toLocaleString())
  },

  number0: function (value) {
    return $('<td>')
      .addClass('text-right')
      .text(FormatMethods.numberFixed(value, 0))
  },

  number1: function (value) {
    return $('<td>')
      .addClass('text-right')
      .text(FormatMethods.numberFixed(value, 1))
  },

  number2: function (value) {
    return $('<td>')
      .addClass('text-right')
      .text(FormatMethods.numberFixed(value, 2))
  }
}

function unpackData(table, data, formats) {
  const tbody = $(table).find('tbody');
  if (tbody.children().length > 0) {
    tbody.html('')
  }

  data.forEach(function (row) {
    const tr = $('<tr>');
    row.forEach(function (value, index) {
      tr.append(formats[index](value))
    })
    tbody.append(tr);
  })
}
