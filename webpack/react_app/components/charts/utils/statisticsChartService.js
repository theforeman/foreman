import _ from 'lodash';
import donut from './c3DonutService';

export default {
  getChartConfig: getChartConfig,
  getModalChartConfig: getModalChartConfig,
  setTitle: setTitle,
  syncConfigData: syncConfigData
};

function getChartConfig(details) {
  let config = donut.getDonutConfig();

  config.bindto = '#' + details.id + 'Chart';

  if (!details.search.match(/=$/)) {
    config.data.onclick = getClickHandler(details.search);
  }
  config.data.columns = [];

  return config;
}

function getModalChartConfig(details) {
  let config = donut.getLargeDonutConfig();

  config.data.columns = [];

  return config;
}

function syncConfigData(config, data) {
  config.data.columns = data;
  config.data.names = data ? data.reduce(getDataNames, {}) : null;
}

function setTitle(config) {
  const data = config.data;
  const max = getMax(data.columns);
  const total = getTotal(data.columns);

  if (total) {
    let title = _.round(100 * max[1] / total, 1).toString() + '%';

    window.patternfly.pfSetDonutChartTitle(config.bindto, title, data.names[max[0]]);
  }
}

function getTotal(columns) {
  return _.reduce(columns, function (sum, item) {
    return sum + item[1];
  }, 0);
}

function getMax(columns) {
  return columns.reduce(function (prev, curr) {
    return curr[1] > prev[1] ? curr : prev;
  });
}

// eslint-disable-next-line no-unused-vars
function getDataNames(prev, val) {
  let key = val[0];

  prev[key] = key.replace(/_/g, ' ');

  return prev;
}

function getClickHandler(url) {
  if (url) {
    // eslint-disable-next-line no-unused-vars
    return function (data, element) {
      let val = data.id;

      window.tfm.tools.showSpinner();

      if (url.includes('~VAL1~') || url.includes('~VAL2~')) {
        const vals = val.split(' ');

        let val1 = encodeURIComponent(vals[0]), val2 = encodeURIComponent(vals[1]);

        url = url.replace('~VAL1~', val1).replace('~VAL2~', val2);
      } else {
        if (val.includes(' ')) {
          val = '"' + val + '"';
        }
        url = url.replace('~VAL~', val);
      }
      window.location.href = url;
    };
  }
  return null;
}
