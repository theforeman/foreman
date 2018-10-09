import uuidV1 from 'uuid/v1';
import { getChartConfig } from './ChartService';

export const getDonutChartConfig = ({ data, config, onclick, id = uuidV1() }) =>
  getChartConfig({
    type: 'donut',
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
