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

// data = { low: 10, high: 30, mean: 25, current: 17 }
window.price_target_chart = function(canvas, data) {
    canvas = $(canvas);
    if (canvas.length === 0) return;

    const prices = [data['low'], data['high'], data['current']];
    let min = Math.min(...prices);
    let max = Math.max(...prices);
    const offset = (max - min) / 10;
    min -= offset;
    max += offset;

    const dat = {
        datasets: [{
            label: 'Low\n' + formatCurrency(data['low']),
            xAxisID: 'x-axis-1',
            yAxisID: 'y-axis-1',
            borderColor: '#111111',
            backgroundColor: '#111111',
            data: [{
                x: data['low'],
                y: 0,
            }]
        }, {
            label: 'High\n' + formatCurrency(data['high']),
            xAxisID: 'x-axis-1',
            yAxisID: 'y-axis-1',
            borderColor: '#111111',
            backgroundColor: '#111111',
            data: [{
                x: data['high'],
                y: 0,
            }]
        }, {
            label: "Average\n" + formatCurrency(data['mean']),
            xAxisID: 'x-axis-1',
            yAxisID: 'y-axis-1',
            borderColor: '#111111',
            backgroundColor: '#ffffff',
            data: [{
                x: data['mean'],
                y: 0,
            }]
        }, {
            label: formatCurrency(data['current']) + '\nCurrent',
            xAxisID: 'x-axis-1',
            yAxisID: 'y-axis-1',
            borderColor: '#0F69FF',
            backgroundColor: '#0F69FF',
            data: [{
                x: data['current'],
                y: 0,
            }]
        }]
    };

    Chart.Scatter(canvas, {
        data: dat,
        options: {
            responsive: true,
            hoverMode: 'nearest',
            intersect: true,
            legend: {
                display: false,
            },
            scales: {
                xAxes: [{
                    position: 'bottom',
                    display: true,
                    gridLines: {
                        lineWidth: 0,
                    },
                    ticks: {
                        min: min,
                        max: max,
                        display: false,
                    },
                }],
                yAxes: [{
                    type: 'linear',
                    display: true,
                    position: 'left',
                    id: 'y-axis-1',
                    gridLines: {
                        zeroLineColor: '#888888',
                        zeroLineWidth: 2,
                        drawTicks: false,
                        lineWidth: 0,
                        drawBorder: false,
                        drawOnChartArea: true,
                    },
                    ticks: {
                        display: false
                    }
                }],
            },
            plugins: {
                datalabels: {
                    display: true,
                    color: function(value) {
                        return value.dataset.borderColor;
                    },
                    align: function(value) {
                        return value.datasetIndex < 3 ? 'top' : 'bottom';
                    },
                    font: {
                        weight: 'bold'
                    },
                    formatter: function(value, context) {
                        return context.dataset.label;
                    }
                }
            }
        }
    });
}
