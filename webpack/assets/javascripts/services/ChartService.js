import uuidV1 from 'uuid/v1';
import { donutChartConfig, donutLargeChartConfig } from './ChartService.consts';

const sizeConfig = {
  regular: donutChartConfig,
  large: donutLargeChartConfig,
};

function getChartConfig({
  data, config, onclick, id = uuidV1(),
}) {
  if (!data) {
    return {};
  }
  const chartConfigForType = sizeConfig[config];
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
    data: chartData,
    id,
  };
}

export const getDonutChartConfig = ({
  data, config, onclick, id = uuidV1(),
}) =>
  getChartConfig({
    data,
    config,
    onclick,
    id,
  });


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
