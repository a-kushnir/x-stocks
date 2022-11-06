import ApplicationController from 'controllers/application_controller';
import { destroyChart } from 'helpers';

export default class extends ApplicationController {
  connect() {
    this.render();
  }

  disconnect() {
    destroyChart(this.element);
  }

  get data() {
    return JSON.parse(this.element.dataset.earningsChartValue);
  }

  render() {
    const { labels, estimate, actual } = this.data;

    const config = {
      type: 'line',
      data: {
        labels: labels,
        datasets: [
          {
            label: 'Actual',
            backgroundColor: function (pointItem) {
              const est =
                pointItem.chart.data.datasets[1].data[pointItem.dataIndex];
              const act = pointItem.dataset.data[pointItem.dataIndex];
              return est > act ? '#FF333A' : '#00C073';
            },
            borderColor: function (pointItem) {
              const est =
                pointItem.chart.data.datasets[1].data[pointItem.dataIndex];
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
          },
          {
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
          },
        ],
      },
      options: {
        responsive: true,
        legend: {
          display: false,
        },
        tooltips: {
          mode: 'index',
          intersect: false,
        },
        hover: {
          mode: 'nearest',
          intersect: true,
        },
        scales: {
          xAxes: [
            {
              display: true,
            },
          ],
          yAxes: [
            {
              display: true,
            },
          ],
        },
        plugins: {
          datalabels: {
            display: false,
          },
        },
      },
    };

    new Chart(this.element, config);
  }
}
