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
    return JSON.parse(this.element.dataset.priceTargetChartValue);
  }

  render() {
    const { low, high, mean, current } = this.data;

    const prices = [low, high, current];
    let min = Math.min(...prices);
    let max = Math.max(...prices);
    const offset = (max - min) / 10;
    min -= offset;
    max += offset;

    const data = {
      datasets: [{
        label: 'Low\n' + formatCurrency(low),
        xAxisID: 'x-axis-1',
        yAxisID: 'y-axis-1',
        borderColor: '#111111',
        backgroundColor: '#111111',
        data: [{
          x: low,
          y: 0,
        }]
      }, {
        label: 'High\n' + formatCurrency(high),
        xAxisID: 'x-axis-1',
        yAxisID: 'y-axis-1',
        borderColor: '#111111',
        backgroundColor: '#111111',
        data: [{
          x: high,
          y: 0,
        }]
      }, {
        label: "Average\n" + formatCurrency(mean),
        xAxisID: 'x-axis-1',
        yAxisID: 'y-axis-1',
        borderColor: '#111111',
        backgroundColor: '#ffffff',
        data: [{
          x: mean,
          y: 0,
        }]
      }, {
        label: formatCurrency(current) + '\nCurrent',
        xAxisID: 'x-axis-1',
        yAxisID: 'y-axis-1',
        borderColor: '#0F69FF',
        backgroundColor: '#0F69FF',
        data: [{
          x: current,
          y: 0,
        }]
      }]
    };

    const config = {
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
    };

    const chart = Chart.Scatter(this.element, config);

    if (mean === low || mean === high) {
      if (mean === low) chart.getDatasetMeta(0).hidden = true;
      if (mean === high) chart.getDatasetMeta(1).hidden = true;
      chart.update();
    }
  }
}
