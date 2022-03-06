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
