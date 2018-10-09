const enums = {
  SIZE: {
    LARGE: { height: 500 },
    REGULAR: { width: 240, height: 240 },
    MEDIUM: { width: 350, height: 350 },
  },
  WIDTH: {
    SMALL: 15,
    MEDIUM: 20,
    LARGE: 25,
  },
};

const barChartEnums = {
  SIZE: {
    LARGE: { height: 500 },
    REGULAR: { width: 350, height: 350 },
    SMALL: { height: 290 },
  },
  WIDTH: { ...enums.width },
};

export const chartConfig = {
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

export const donutChartConfig = {
  ...chartConfig,
  donut: {
    width: enums.WIDTH.SMALL,
    label: { show: false },
  },
};

export const donutMediumChartConfig = {
  ...donutChartConfig,
  size: enums.SIZE.MEDIUM,
  legend: { show: false },
  donut: {
    ...donutChartConfig.donut,
    width: enums.WIDTH.MEDIUM,
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

export const barChartConfig = {
  ...chartConfig,
  size: barChartEnums.SIZE.REGULAR,
  padding: null,
};

export const smallBarChartConfig = {
  ...barChartConfig,
  size: barChartEnums.SIZE.SMALL,
};
