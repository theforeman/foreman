import { round } from 'lodash';
import uuidV1 from 'uuid/v1';
import { donutChartConfig, donutLargeChartConfig } from './ChartService.consts';

function getChartConfigForType(type) {
  switch (type) {
    case 'donut':
      return donutChartConfig;
    case 'donutLarge':
      return donutLargeChartConfig;
    default:
      throw new Error(`unknown chart type ${type}`);
  }
}

function getChartConfig({
  data, type, onclick, id = uuidV1(),
}) {
  if (!data) {
    return {};
  }
  const chartConfigForType = getChartConfigForType(type);
  const nonEmptyData = data.filter((d) => {
    const amount = d[1];

    return amount !== 0;
  });

  const chartData = nonEmptyData.reduce(
    (curr, next) => {
      const key = next[0];
      const color = next[2];

      const names = {
        ...curr.names,
        [key]: key,
      };

      const retVal = {
        ...curr,
        names,
      };

      if (color) {
        return Object.assign({}, retVal, {
          colors: {
            ...(retVal.colors || {}),
            [key]: color,
          },
        });
      }

      return retVal;
    },
    {
      ...chartConfigForType.data,
      columns: nonEmptyData,
      names: {},
      onclick,
    },
  );

  return {
    ...chartConfigForType,
    bindto: `[data-id="${id}"]`,
    data: chartData,
    id,
  };
}

export const getPieChartConfig = ({ data, onclick, id = uuidV1() }) =>
  getChartConfig({
    data,
    type: 'donut',
    onclick,
    id,
  });

export const getLargePieChartConfig = ({ data, onclick, id = uuidV1() }) =>
  getChartConfig({
    data,
    type: 'donutLarge',
    onclick,
    id,
  });

function getTotal(columns) {
  return columns.reduce((sum, item) => sum + item[1], 0);
}

function getMax(columns) {
  return columns.reduce((prev, curr) => (curr[1] > prev[1] ? curr : prev));
}

export const setTitle = (config) => {
  const { data } = config;
  const max = getMax(data.columns);
  const total = getTotal(data.columns);

  if (total) {
    const start = 100 * max[1];
    const title = `${round(start / total, 1).toString()}%`;

    window.patternfly.pfSetDonutChartTitle(config.bindto, title, data.names[max[0]]);
  }
};

export const navigateToSearch = (url, data) => {
  let val = data.id;
  let setUrl;

  window.tfm.tools.showSpinner();

  if (url.includes('~VAL1~') || url.includes('~VAL2~')) {
    const vals = val.split(' ');

    const val1 = encodeURIComponent(vals[0]);
    const val2 = encodeURIComponent(vals[1]);

    setUrl = url.replace('~VAL1~', val1).replace('~VAL2~', val2);
  } else {
    if (val.includes(' ')) {
      val = `"${val}"`;
    }
    setUrl = url.replace('~VAL~', val);
  }
  window.location.href = setUrl;
};
