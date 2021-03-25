import uuidV1 from 'uuid/v1';
import Immutable from 'seamless-immutable';
import {
  donutChartConfig,
  donutLargeChartConfig,
  donutMediumChartConfig,
  barChartConfig,
  mediumBarChartConfig,
  smallBarChartConfig,
  lineChartConfig,
  timeseriesLineChartConfig,
  timeseriesAreaChartConfig,
} from './ChartService.consts';

const chartsSizeConfig = {
  area: {
    timeseries: timeseriesAreaChartConfig,
  },
  bar: {
    regular: barChartConfig,
    small: smallBarChartConfig,
    medium: mediumBarChartConfig,
  },
  donut: {
    regular: donutChartConfig,
    medium: donutMediumChartConfig,
    large: donutLargeChartConfig,
  },
  line: {
    regular: lineChartConfig,
    timeseries: timeseriesLineChartConfig,
  },
};

const doDataExist = data => {
  if (!data || data.length === 0) {
    return false;
  }
  return data.reduce((curr, next) => {
    const value = next[1];

    return value !== 0 ? true : curr;
  }, false);
};

const getColors = data =>
  data.reduce((curr, next) => {
    const key = next[0];
    const color = next[2];

    return color ? { ...curr, [key]: color } : curr;
  }, {});

export const getChartConfig = ({
  type,
  data,
  config,
  onclick,
  id = uuidV1(),
}) => {
  const chartConfigForType = chartsSizeConfig[type][config];
  const colors = getColors(data);
  const colorsSize = Object.keys(colors).length;
  const dataExists = doDataExist(data);
  const longNames = {};

  let dataWithShortNames = [];

  if (dataExists) {
    dataWithShortNames = data.map(val => {
      const item = Immutable.asMutable(val.slice());
      const longName = item[0];
      item[0] = item[0].length > 30 ? `${val[0].substring(0, 10)}...` : item[0];
      longNames[item[0]] = longName;
      return item;
    });
  }

  return {
    ...chartConfigForType,
    id,
    data: {
      columns: dataExists ? dataWithShortNames : [],
      onclick,
      ...(colorsSize > 0 ? { colors } : {}),
    },
    // eslint-disable-next-line no-shadow
    tooltip: { format: { name: (name, ratio, id, idx) => longNames[id] } },

    onrendered: () => {
      dataWithShortNames.forEach(colData => {
        const nameOfClass = colData[0].replace(/\W/g, '-');
        const selector = `.c3-legend-item-${nameOfClass} > title`;
        // eslint-disable-next-line no-undef
        const hasTooltip = d3.select(selector)[0][0];

        if (!hasTooltip) {
          // eslint-disable-next-line no-undef
          d3.select(`.c3-legend-item-${nameOfClass}`)
            .append('svg:title')
            .text(longNames[colData[0]]);
        }
      });
    },
  };
};
