export function destroyChart(canvas) {
  for (const key in Chart.instances) {
    const chart = Chart.instances[key];
    if (chart.canvas === canvas) {
      chart.destroy();
    }
  }
}
