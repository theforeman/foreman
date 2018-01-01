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
    pattern: ['#0088ce', '#cc0000', '#ec7a08', '#3f9c35', '#005c66', 'f9d67a'],
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

export const donutLargeChartConfig = {
  ...donutChartConfig,
  size: enums.SIZE.LARGE,
  legend: { show: true, position: 'bottom' },
  donut: {
    ...donutChartConfig.donut,
    width: enums.WIDTH.LARGE,
  },
};
