import ApplicationController from "controllers/application_controller";
import { destroy_chart } from "helpers/chart_helper";

export default class extends ApplicationController {
  connect() {
    this.render();
  }

  disconnect() {
    destroy_chart(this.element);
  }

  get data() {
    return JSON.parse(this.element.dataset.recommendationDetailsChartValue);
  }

  get min() {
    return JSON.parse(this.element.dataset.recommendationDetailsChartMinValue);
  }

  render() {
    const min = this.min;

    new Chart(this.element, {
      type: 'bar',
      data: this.data,
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
            formatter: function(value) {
              return value >= min && value > 0 ? Math.round(value) : null;
            }
          }
        }
      },
    });
  }
}
