import ApplicationController from "controllers/application_controller";
import { destroyChart } from "helpers/chart_helper";

export default class extends ApplicationController {
  connect() {
    this.render();
  }

  disconnect() {
    destroyChart(this.element);
  }

  get data() {
    return JSON.parse(this.element.dataset.recommendationDetailsChartValue);
  }

  render() {
    const { labels, datasets, min } = this.data;

    const config = {
      type: 'bar',
      data: {
        labels: labels,
        datasets: datasets
      },
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
      }
    };

    new Chart(this.element, config);
  }
}
