/** Process raw data into chart series. Backend may send Unix seconds or milliseconds. */
export const processChartData = (data, xAxisDataLabel) => {
  if (!data || data.length === 0) return null;
  const timeColumn = data.find(col => col[0] === xAxisDataLabel);
  if (!timeColumn) return null;
  const timestamps = timeColumn.slice(1);
  const toMs = val => {
    const n = Number(val);
    return n >= 1e12 ? n : n * 1000;
  };
  const dates = timestamps.map(t => new Date(toMs(t)));
  const series = data
    .filter(col => col[0] !== xAxisDataLabel)
    .map(col => ({
      name: col[0],
      data: col.slice(1).map((value, index) => ({
        x: dates[index],
        y: value ?? 0,
        name: col[0],
      })),
    }));
  return series.length > 0 ? series : null;
};

/** Compute y-axis tick values from chart data. */
export const getYTickValues = (chartData, config, hiddenSeries) => {
  if (!chartData?.length) return undefined;
  let maxY = 0;
  if (config === 'timeseries') {
    const n = chartData[0].data.length;
    for (let i = 0; i < n; i++) {
      let sum = 0;
      chartData.forEach(chartSeries => {
        if (!hiddenSeries.has(chartSeries.name))
          sum += chartSeries.data[i]?.y ?? 0;
      });
      maxY = Math.max(maxY, sum);
    }
  } else {
    chartData
      .filter(s => !hiddenSeries.has(s.name))
      .forEach(s => {
        s.data.forEach(point => {
          maxY = Math.max(maxY, point.y ?? 0);
        });
      });
  }
  if (maxY <= 0) return [0, 0.5, 1.0];
  const step = Math.max(0.1, Math.ceil((maxY / 4) * 10) / 10);
  return [0, 1, 2, 3, 4, 5].map(i => Math.round(i * step * 10) / 10);
};
