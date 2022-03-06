import ApplicationController from "controllers/application_controller";

export default class extends ApplicationController {
  connect() {
    this.render();
  }

  disconnect() {
    for (const key in Chart.instances) {
      const chart = Chart.instances[key];
      if (chart.canvas === this.element) {
        chart.destroy();
      }
    }
  }

  get value() {
    return parseFloat(this.element.dataset.recommendationMeanChartValue);
  }

  render() {
    const data = {
      datasets: [{
        label: this.value,
        xAxisID: 'x-axis-1',
        yAxisID: 'y-axis-1',
        borderColor: '#0F69FF',
        backgroundColor: '#0F69FF',
        data: [{
          x: this.value,
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

    Chart.Scatter(this.element, {
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
}
