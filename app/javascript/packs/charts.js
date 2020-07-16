window.dividends_month_chart = function(canvas, data) {
    canvas = $(canvas);
    if (canvas.length === 0) return;

    new Chart(canvas, {
        type: 'horizontalBar',
        data: data,
        options: {
            legend: {
                display: false,
            },
            tooltips: {
                enabled: false
            },
            scales: {
                yAxes: [{
                    gridLines: {
                        lineWidth: 0,
                    },
                }],
                xAxes: [{
                    ticks: {
                        beginAtZero: true,
                        callback: function (value, index, values) {
                            return '$' + value;
                        }
                    },
                }]
            },
            plugins: {
                datalabels: {
                    anchor: 'start',
                    align: 'end',
                    color: '#111111',
                    formatter: function (value, context) {
                        return value > 0 ? formatCurrency(value) : null;
                    }
                }
            }
        }
    });
}
