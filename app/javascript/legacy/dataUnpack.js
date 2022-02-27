const FormatMethods = {
  safeLink: function(value) {
    return String(value).replace('/', '%2F');
  },

  currency: function (value, minimumFractionDigits, maximumFractionDigits) {
    if (value === null) return '';

    const formatter = new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: minimumFractionDigits,
      maximumFractionDigits: maximumFractionDigits
    });
    return formatter.format(value);
  },

  commarize: function(value) {
    if (Math.abs(value) >= 1e3) {
      const minus = value < 0;
      if (minus) value = -value;

      const units = ["k", "M", "B", "T"];
      const unit = Math.floor((value.toFixed(0).length - 1) / 3) * 3;
      let num = (value / ('1e'+unit)).toFixed(2);
      const unitname = units[Math.floor(unit / 3) - 1];

      if (minus) num = `-${num}`;
      return `$${num} ${unitname}`;
    }
    return value.toLocaleString();
  },

  invLerp: function(min, max, value) {
    if (min < max) {
      if (value <= min) return 0;
      if (value >= max) return 1;
    }
    else {
      if (value >= min) return 0;
      if (value <= max) return 1;
    }

    return (value - min) / (max - min);
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
        )
      )

      .append($('<a>')
        .addClass(note ? 'has-note' : null)
        .attr('href', `/stocks/${FormatMethods.safeLink(symbol)}`)
        .text(symbol)
      )
  },

  flag: function(value) {
    return $('<td>')
      .attr('data-sort', value ? value : '-')
      .append($('<div>')
        .addClass('symbol-logo')
        .addClass('text-center')
        .append($('<img>')
          .attr('src', value ? `/img/flags-iso/flat/24/${value}.png` : null)
        )
      )
  },

  text: function(value) {
    return $('<td>')
      .addClass('text-nowrap')
      .text(value)
  },

  priceRange: function(value) {
    if (value === null) return $('<td>').attr('data-sort', '-');

    const min = value[0], max = value[1], curr = value[2], change = value[3];

    const curr_pct = FormatMethods.invLerp(min, max, curr) * 100;
    const points = change > 0 ? [curr - change, curr] : [curr, curr - change];
    const progress1 = FormatMethods.invLerp(min, max, points[0]) * 100;
    let progress2 = FormatMethods.invLerp(min, max, points[1]) * 100 - progress1;
    if (progress2 < 2) progress2 = 2; // Min width is 2%
    const css_class = (change < 0) ? 'bg-danger' : 'bg-success'

    const progress = `<div class="progress">
      <div class="progress-bar" role="progressbar" style="width: ${progress1}%; background-color: transparent;"></div>
      <div class="progress-bar ${css_class}" role="progressbar" style="width: ${progress2}%"></div>
      </div>`;
    const label = `<small>
      <span class="float-left">${FormatMethods.currency(min)}</span>
      <span class="float-right">${FormatMethods.currency(max)}</span>
      </small>`;

    return $('<td>')
      .attr('data-sort', curr_pct)
      .addClass('price-range')
      .addClass('text-nowrap')
      .html(progress + label);
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

  currency: function (value, minimumFractionDigits, maximumFractionDigits) {
    if (value === null) {
      return $('<td>')
        .attr('data-sort', '0');
    }

    return $('<td>')
      .attr('data-sort', value)
      .addClass('text-right')
      .text(FormatMethods.currency(value, minimumFractionDigits, maximumFractionDigits))
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

  currencyDiv: function(value) {
    if (value === null) return $('<td>');
    return isNaN(value) ?
      Formats.warn(value) :
      Formats.currency(value, undefined, 4);
  },

  bigMoney: function(value) {
    if (value === null) {
      return $('<td>')
        .attr('data-sort', '0');
    }

    return $('<td>')
      .attr('data-sort', value)
      .addClass('text-right')
      .text(FormatMethods.commarize(value))
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
    if (value === null) {
      return $('<td>')
        .attr('data-sort', '0');
    }

    value = new Date(`${value}T00:00:00`);
    return $('<td>')
      .addClass('text-right')
      .addClass('text-nowrap')
      .attr('data-sort', $.format.date(value, 'yyyyMMdd'))
      .text($.format.date(value, 'MMM, d yyyy'))
  },

  dateFuture: function (value) {
    if (value === null) {
      return $('<td>')
        .attr('data-sort', '0');
    }

    value = new Date(`${value}T00:00:00`);
    const klass = (value <= future_ex_date) ? 'text-muted-alt' : '';

    return $('<td>')
      .addClass('text-right')
      .addClass('text-nowrap')
      .addClass(klass)
      .attr('data-sort', $.format.date(value, 'yyyyMMdd'))
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
  },

  direction: function(value) {
    if (value === null) {
      return $('<td>')
        .attr('data-sort', '0');
    }

    const dir = value > 0 ? 'up' : (value < 0 ? 'down' : 'right');
    const col = value > 0 ? 'success' : (value < 0 ? 'danger' : 'muted');
    return $('<td>')
      .addClass('text-center')
      .attr('data-sort', value)
      .html(`<i class='fas fa-lg fa-caret-${dir} text-${col}'> </i> ${Math.abs(value) > 1 ? Math.abs(value) : ''}`)
  },

  frequency: function(value) {
    if (value === null) {
      return $('<td>')
        .attr('data-sort', '0');
    }

    return $('<td>')
      .attr('data-sort', value[1])
      .text(value[0])
  }
}

function unpackData(table, data, formats) {
  const tbody = $(table).find('tbody');
  if (tbody.children().length > 0) return;

  data.forEach(function (row) {
    const tr = $('<tr>');
    row.forEach(function (value, index) {
      tr.append(formats[index](value))
    })
    tbody.append(tr);
  })
}
