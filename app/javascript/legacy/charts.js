window.chart_office_colors = [
    '#4472C4', '#ED7D31', '#A5A5A5', '#FFC000', '#5B9BD5', '#70AD47',
    '#264478', '#9E480E', '#636363', '#997300', '#255E91', '#43682B',
    '#698ED0', '#F1975A', '#B7B7B7', '#FFCD33', '#7CAFDD', '#8CC168',
    '#335AA1', '#D26012', '#848484', '#CC9A00', '#327DC2', '#5A8A39',
    '#8FAADC', '#F4B183', '#C9C9C9', '#FFD966', '#9DC3E6', '#A9D18E',
    '#203864', '#843C0C', '#525252', '#7F6000', '#1F4E79', '#385723',
    '#7C9CD6', '#F2A46F', '#C0C0C0', '#FFD34D', '#8CB9E2', '#9AC97B',
    '#2C4F8C', '#B85410', '#747474', '#B38600', '#2B6DA9', '#4E7932',
    '#A2B9E2', '#F6BE98', '#D2D2D2', '#FFDF7F', '#ADCDEA', '#B7D8A1',
]

window.destroy_all_charts = function () {
    for (const key in Chart.instances) {
        Chart.instances[key].destroy()
    }
}

document.addEventListener("turbo:load", () => {
    destroy_all_charts();
})

window.dividends_month_chart = function(canvas, data) {
    canvas = $(canvas);
    if (canvas.length === 0) return;

    const chart = new Chart(canvas, {
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
                            return formatCurrency(value);
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
    canvas.data('chart', chart);
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

    const chart = Chart.Scatter(canvas, {
        data: dat,
        options: {
            responsive: true,
            hoverMode: 'nearest',
            intersect: true,
            legend: {
                display: false,
            },
            tooltips: {
              enabled: false,
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

    if (data['mean'] === data['low'] ||
        data['mean'] === data['high']) {
        if (data['mean'] === data['low'])
            chart.getDatasetMeta(0).hidden = true;
        if (data['mean'] === data['high'])
            chart.getDatasetMeta(1).hidden = true;
        chart.update();
    }
}

window.recommendation_details_chart = function(canvas, data, min) {
    canvas = $(canvas);
    if (canvas.length === 0) return;

    new Chart(canvas, {
        type: 'bar',
        data: data,
        options: {
            scales: {
                xAxes: [{
                    stacked: true
                }],
                yAxes: [{
                    ticks: { stepSize: min <= 1 ? 1 : null },
                    stacked: true,
                }]
            },
            legend: {
                position: 'right',
                reverse: true,
                labels: {
                    boxWidth: 12
                }
            },
            plugins: {
                datalabels: {
                    display: true,
                    color: 'white',
                    font: {
                        weight: 'bold'
                    },
                    formatter: function(value, context) {
                        return value >= min && value > 0 ? Math.round(value) : null;
                    }
                }
            }
        },
    });
}

window.recommendation_mean_chart = function(canvas, value) {
    canvas = $(canvas);
    if (canvas.length === 0) return;

    const data = {
        datasets: [{
            label: value,
            xAxisID: 'x-axis-1',
            yAxisID: 'y-axis-1',
            borderColor: '#0F69FF',
            backgroundColor: '#0F69FF',
            data: [{
                x: value,
                y: 0,
            }]
        }, {
            label: 'Strong\n  Buy',
            xAxisID: 'x-axis-1',
            yAxisID: 'y-axis-1',
            borderColor: '#111111',
            backgroundColor: '#ffffff',
            data: [{
                x: 1,
                y: 0,
            }]
        }, {
            label: 'Buy',
            xAxisID: 'x-axis-1',
            yAxisID: 'y-axis-1',
            borderColor: '#111111',
            backgroundColor: '#ffffff',
            data: [{
                x: 2,
                y: 0,
            }]
        }, {
            label: 'Hold',
            xAxisID: 'x-axis-1',
            yAxisID: 'y-axis-1',
            borderColor: '#111111',
            backgroundColor: '#ffffff',
            data: [{
                x: 3,
                y: 0,
            }]
        }, {
            label: 'Sell',
            xAxisID: 'x-axis-1',
            yAxisID: 'y-axis-1',
            borderColor: '#111111',
            backgroundColor: '#ffffff',
            data: [{
                x: 4,
                y: 0,
            }]
        }, {
            label: 'Strong\n  Sell',
            xAxisID: 'x-axis-1',
            yAxisID: 'y-axis-1',
            borderColor: '#111111',
            backgroundColor: '#ffffff',
            data: [{
                x: 5,
                y: 0,
            }]
        }]
    };

    Chart.Scatter(canvas, {
        data: data,
        options: {
            responsive: true,
            hoverMode: 'nearest',
            intersect: true,
            legend: {
                display: false,
            },
            tooltips: {
                enabled: false,
            },
            scales: {
                xAxes: [{
                    position: 'bottom',
                    display: true,
                    gridLines: {
                        lineWidth: 0,
                    },
                    ticks: {
                        min: 0.5,
                        max: 5.5,
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
                        return value.datasetIndex < 1 ? 'top' : 'bottom';
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

function copyString(str) {
    return `${str}`;
}
function truncateLabel(str, n) {
    const s = copyString(str);
    return (s.length > n + 3) ? `${s.substr(0, n-1)}…` : s;
}

window.allocation_chart = function(canvas, values, labels, symbols = null) {
    canvas = $(canvas);
    if (canvas.length === 0) return;

    const total = values.reduce(function(a, b){
        return a + b;
    }, 0);

    const data = {
        datasets: [{
            data: values,
            symbols: symbols,
            backgroundColor: chart_office_colors,
        }],
        labels: labels.map(label => truncateLabel(label, 12))
    };

    new Chart(canvas, {
        type: 'pie',
        data: data,
        options: {
            legend: {
                position: 'right',
                labels: {
                    boxWidth: 12
                },
            },
            tooltips: {
                callbacks: {
                    label: function(tooltipItem, data) {
                        const label = labels[tooltipItem.index];
                        const value = data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index];

                        let share = Number(value / total * 100);
                        if (share >= 10) share = share.toFixed(0)
                        else if (share >= 1) share = share.toFixed(1)
                        else if (share >= 0.1) share = share.toFixed(2);

                        const symbols = data.datasets[tooltipItem.datasetIndex].symbols;
                        const symbol = symbols !== null ? ` (${symbols[tooltipItem.index]})` : '';

                        return `${label}${symbol}: ${formatCurrency(value)} (${share}%)`;
                    }
                }
            },
            plugins: {
                datalabels: {
                    display: false
                }
            }
        }
    });
}

window.earnings_chart = function(canvas, estimate, actual, labels) {
    canvas = $(canvas);
    if (canvas.length === 0) return;

    const config = {
        type: 'line',
        data: {
            labels: labels,
            datasets: [{
                label: 'Actual',
                backgroundColor: function(pointItem) {
                    const est = pointItem.chart.data.datasets[1].data[pointItem.dataIndex];
                    const act = pointItem.dataset.data[pointItem.dataIndex];
                    return est > act ? '#FF333A' : '#00C073';
                },
                borderColor: function(pointItem) {
                    const est = pointItem.chart.data.datasets[1].data[pointItem.dataIndex];
                    const act = pointItem.dataset.data[pointItem.dataIndex];
                    return est > act ? '#FF333A' : '#00C073';
                },
                showLine: false,
                pointRadius: 8,
                pointHoverRadius: 9,
                pointBorderWidth: 2,
                pointHoverBorderWidth: 2,
                data: actual,
                fill: false,
            }, {
                label: 'Estimate',
                fill: false,
                pointHoverBackgroundColor: 'white',
                backgroundColor: 'white',
                borderColor: '#0F69FF',
                showLine: false,
                pointRadius: 8,
                pointHoverRadius: 9,
                pointBorderWidth: 2,
                pointHoverBorderWidth: 2,
                data: estimate,
            }]
        },
        options: {
            responsive: true,
            legend: {
                display: false
            },
            tooltips: {
                mode: 'index',
                intersect: false,
            },
            hover: {
                mode: 'nearest',
                intersect: true
            },
            scales: {
                xAxes: [{
                    display: true,
                }],
                yAxes: [{
                    display: true,
                }]
            },
            plugins: {
                datalabels: {
                    display: false,
                }
            },
        }
    };

    new Chart(canvas, config);
}

function commarize(value) {
    if (Math.abs(value) >= 1e3) {
        const minus = value < 0;
        if (minus) value = -value;

        const units = ["k", "M", "B", "T"];
        const unit = Math.floor((value.toFixed(0).length - 1) / 3) * 3;
        let num = (value / ('1e'+unit)).toFixed(2);
        const unitname = units[Math.floor(unit / 3) - 1];

        if (minus) num = `-${num}`;
        return `${num}${unitname}`;
    }
   return value.toLocaleString();
}

window.financials_chart = function(canvas, revenue, earnings, labels, outstandingShares) {
    canvas = $(canvas);
    if (canvas.length === 0) return;

    const config = {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [{
                label: 'Revenue',
                fill: false,
                backgroundColor: '#00C073',
                borderColor: '#00C073',
                showLine: false,
                pointRadius: 8,
                pointHoverRadius: 9,
                pointBorderWidth: 2,
                pointHoverBorderWidth: 2,
                data: revenue,
            },{
                label: 'Earnings',
                backgroundColor: function(pointItem) {
                    const value = pointItem.dataset.data[pointItem.dataIndex];
                    return value < 0 ? '#FF333A' : '#0F69FF';
                },
                borderColor: function(pointItem) {
                    const value = pointItem.dataset.data[pointItem.dataIndex];
                    return value < 0 ? '#FF333A' : '#0F69FF';
                },
                showLine: false,
                pointRadius: 8,
                pointHoverRadius: 9,
                pointBorderWidth: 2,
                pointHoverBorderWidth: 2,
                data: earnings,
                fill: false,
            }]
        },
        options: {
            responsive: true,
            legend: {
                display: false
            },
            tooltips: {
                mode: 'index',
                intersect: false,
                callbacks: {
                    label: function(tooltipItem, data) {
                        const label = data.datasets[tooltipItem.datasetIndex].label;
                        const raw = data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index];
                        const value = commarize(raw);

                        if (outstandingShares) {
                            const perShare = (raw / outstandingShares).toFixed(2);
                            return `${label}: ${value} | ${perShare}`;
                        } else {
                            return `${label}: ${value}`;
                        }
                    }
                }
            },
            hover: {
                mode: 'nearest',
                intersect: true
            },
            scales: {
                xAxes: [{
                    display: true,
                }],
                yAxes: [{
                    display: true,
                    ticks: {
                        beginAtZero: true,
                        callback: function(value, index, values) {
                            return commarize(value);
                        }
                    }
                }]
            },
            plugins: {
                datalabels: {
                    display: false,
                }
            }
        }
    };

    new Chart(canvas, config);
}
