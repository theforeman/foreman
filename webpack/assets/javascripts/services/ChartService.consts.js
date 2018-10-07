const enums = {
  SIZE: {
    LARGE: { height: 500 },
    REGULAR: { width: 240, height: 240 },
  },
  WIDTH: {
    SMALL: 15,
    LARGE: 25,
  },
};

export const donutChartConfig = {
  donut: {
    width: enums.WIDTH.SMALL,
    label: { show: false },
  },
  data: {
    columns: [],
  },
  color: {
    pattern: ['#0088ce', '#ec7a08', '#3f9c35', '#005c66', 'f9d67a', '#703fec'],
  },
  tooltip: {
    show: true,
  },
  legend: { show: false },
  padding: {
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
  },
  size: enums.SIZE.REGULAR,
};

export const timeseriesChartConfig = {
  data: {
    x: 'time',
    columns: [],
  },
  axis: {
    x: {
      type: 'timeseries',
      tick: {
        fit: false,
      },
    },
  },
  zoom: {
    enabled: true,
  },
  subchart: {
    show: true,
  },
  tooltip: {
    grouped: false,
    format: {
      title: d => new Date(d).toUTCString(),
    },
  },
};

export const donutLargeChartConfig = {
  ...donutChartConfig,
  size: enums.SIZE.LARGE,
  legend: { show: true, position: 'bottom' },
  donut: {
    ...donutChartConfig.donut,
    width: enums.WIDTH.LARGE,
  },
};
