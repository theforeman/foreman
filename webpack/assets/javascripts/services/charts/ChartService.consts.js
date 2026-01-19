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
    pattern: ['#0088ce', '#ec7a08', '#3f9c35', '#005c66', '#f9d67a', '#703fec'],
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

// PF5 Victory Charts Configurations for Donut Charts
// Note: PF5 uses different configuration structure than C3.js
export const donutChartConfig = {
  ...chartConfig,
  // PF5-specific properties
  size: enums.SIZE.REGULAR,
  padding: {
    top: 20,
    left: 20,
    right: 20,
    bottom: 20,
  },
  // innerRadius controls the donut hole size (higher = larger hole)
  // Regular: small donut width means larger inner radius (thinner ring)
  innerRadius: 75, // Approximates C3 width: 15
  donut: {
    width: enums.WIDTH.SMALL,
    label: { show: false },
  },
};

export const donutMediumChartConfig = {
  ...donutChartConfig,
  size: enums.SIZE.MEDIUM,
  padding: {
    top: 20,
    left: 20,
    right: 20,
    bottom: 20,
  },
  innerRadius: 100, // Approximates C3 width: 20
  legend: { show: false },
  donut: {
    ...donutChartConfig.donut,
    width: enums.WIDTH.MEDIUM,
  },
};

export const donutLargeChartConfig = {
  ...donutChartConfig,
  size: enums.SIZE.LARGE,
  padding: {
    top: 20,
    left: 20,
    right: 20,
    bottom: 80, // More space for legend at bottom
  },
  innerRadius: 130, // Approximates C3 width: 25
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
  axis: {
    x: {
      type: 'timeseries',
      tick: {
        format: date => new Intl.DateTimeFormat(intl.locale).format(date),
        rotate: -40,
      },
    },
  },
  padding: {
    top: 10,
    bottom: 70,
    left: 30,
    right: 20,
  },
};

export const areaChartConfig = {
  ...chartConfig,
  legend: { show: true },
};

export const timeseriesAreaChartConfig = {
  ...areaChartConfig,
  axis: {
    x: {
      type: 'timeseries',
      tick: {
        format: date =>
          new Intl.DateTimeFormat(intl.locale, {
            month: 'numeric',
            day: 'numeric',
            hour: 'numeric',
            minute: 'numeric',
          }).format(date),
        rotate: -40,
      },
    },
  },
  size: undefined,
  padding: {
    top: 10,
    bottom: 60,
    left: 60,
    right: 20,
  },
};
