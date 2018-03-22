import uuidV1 from 'uuid/v1';
import { donutChartConfig, donutLargeChartConfig } from './ChartService.consts';

const sizeConfig = {
  regular: donutChartConfig,
  large: donutLargeChartConfig,
};

const doDataExist = (data) => {
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

const getChartConfig = ({
  data, config, onclick, id = uuidV1(),
}) => {
  const chartConfigForType = sizeConfig[config];
  const colors = getColors(data);
  const colorsSize = Object.keys(colors).length;

  return {
    ...chartConfigForType,
    id,
    data: {
      columns: doDataExist(data) ? data : [],
      onclick,
      ...(colorsSize > 0 ? { colors } : {}),
    },
  };
};

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
