import ApplicationController from "controllers/application_controller";
import { destroyChart, formatCurrency } from "helpers";

export default class extends ApplicationController {
  connect() {
    this.render();
  }

  disconnect() {
    destroyChart(this.element);
  }

  get data() {
    return JSON.parse(this.element.dataset.monthlyAmountsChartValue);
  }

  render() {
    const config = {
      type: 'horizontalBar',
      data: this.data,
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
              callback: function (value) {
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
            formatter: function (value) {
              return value > 0 ? formatCurrency(value) : null;
            }
          }
        }
      }
    };

    new Chart(this.element, config);
  }
}
