import ApplicationController from 'controllers/application_controller';
import { destroyChart, commarize, diffPct } from 'helpers';

export default class extends ApplicationController {
  connect() {
    this.render();
  }

  disconnect() {
    destroyChart(this.element);
  }

  get data() {
    return JSON.parse(this.element.dataset.buybacksChartValue);
  }

  render() {
    const { labels, values } = this.data;
    const deltas = diffPct(values);

    labels.shift();
    deltas.shift();

    const config = {
      type: 'bar',
      data: {
        labels: labels,
        datasets: [
          {
            label: '',
            backgroundColor: function (pointItem) {
              const value = pointItem.dataset.data[pointItem.dataIndex];
              return value < 0 ? '#FF333A' : '#0F69FF';
            },
            borderColor: function (pointItem) {
              const value = pointItem.dataset.data[pointItem.dataIndex];
              return value < 0 ? '#FF333A' : '#0F69FF';
            },
            showLine: false,
            pointRadius: 8,
            pointHoverRadius: 9,
            pointBorderWidth: 2,
            pointHoverBorderWidth: 2,
            data: deltas,
            fill: false,
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
          callbacks: {
            label: function (tooltipItem, data) {
              const idx = tooltipItem.index;
              const label = data.datasets[tooltipItem.datasetIndex].label;
              const prev = values[idx];
              const curr = values[idx + 1];
              const delta = deltas[idx];
              return `${label}: ${commarize(prev)} → ${commarize(
                curr
              )} | ${commarize(prev - curr)} (${+(delta * 100).toFixed(2)}%)`;
            },
          },
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
              ticks: {
                beginAtZero: true,
                callback: function (value) {
                  return `${+(value * 100).toFixed(3)}%`;
                },
              },
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
