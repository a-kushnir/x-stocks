import ApplicationController from "controllers/application_controller";
import { destroyChart, commarize } from "helpers";

export default class extends ApplicationController {
  connect() {
    this.render();
  }

  disconnect() {
    destroyChart(this.element);
  }

  get data() {
    return JSON.parse(this.element.dataset.financialsChartValue);
  }

  render() {
    const { labels, revenue, earnings, shares } = this.data;

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

              if (shares) {
                const perShare = (raw / shares).toFixed(2);
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
              callback: function(value) {
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

    new Chart(this.element, config);
  }
}
