const enums = {
  SIZE: {
    LARGE: { height: 500 },
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
    type: 'donut',
    columns: [],
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
};

export const donutLargeChartConfig = {
  ...donutChartConfig,
  size: enums.SIZE.LARGE,
  donut: {
    ...donutChartConfig.donut,
    width: enums.WIDTH.LARGE,
  },
};
