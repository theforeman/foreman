import { intl } from '../../react_app/common/I18n';

const enums = {
  SIZE: {
    LARGE: { height: 500 },
    REGULAR: { width: 240, height: 240 },
    MEDIUM: { width: 320, height: 320 },
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
    MEDIUM: { width: 450, height: 320 },
    SMALL: { height: 290 },
  },
  WIDTH: { ...enums.width },
};

const lineChartEnums = {
  SIZE: {
    REGULAR: { width: 1000, height: 350 },
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

export const mediumBarChartConfig = {
  ...barChartConfig,
  size: barChartEnums.SIZE.MEDIUM,
};

export const smallBarChartConfig = {
  ...barChartConfig,
  size: barChartEnums.SIZE.SMALL,
};

export const lineChartConfig = {
  ...chartConfig,
  legend: { show: true },
  size: lineChartEnums.SIZE.REGULAR,
  padding: null,
};

export const timeseriesLineChartConfig = {
  ...lineChartConfig,
  padding: {
    top: 10,
    bottom: 70,
    left: 30,
    right: 20,
  },
  axis: {
    x: {
      type: 'timeseries',
      tick: {
        format: date => new Intl.DateTimeFormat(intl.locale).format(date),
        rotate: -40,
      },
    },
  },
};
