import c3 from 'c3';
import $ from 'jquery';
import _ from 'lodash';

const enums = {
  SIZE: {
    LARGE: { height: 500 }
  },
  WIDTH: {
    SMALL: 15,
    LARGE: 25
  }
};

export default {
  getDonutConfig: getDonutConfig,
  getLargeDonutConfig: getLargeDonutConfig,
  generate: generate,
  enums: enums
};

function getDonutConfig(columns, selector, dataEventHandlers) {

  let config = {
    bindto: selector,
    donut: {
      width: enums.WIDTH.SMALL,
      label: { show: false }
    },
    data: {
      type: 'donut',
      columns: columns,
      names: columns ? columns.reduce(getDataNames, {}) : null
    },
    tooltip: {
      show: true,
      contents: $().pfDonutTooltipContents
    },
    legend: { show: false },
    padding: {
      top: 0,
      left: 0,
      right: 0,
      bottom: 0
    }
  };

  if (dataEventHandlers) {
    Object.assign(config.data, dataEventHandlers);
  }

  return config;
}

function getLargeDonutConfig(columns, selector, dataEventHandlers) {
  let config = getDonutConfig(columns, selector, dataEventHandlers);

  config.size = enums.SIZE.LARGE;
  config.donut.width = enums.WIDTH.LARGE;

  return config;
}

function generate(config) {
  let chart;

  if (config.data.columns && config.data.columns.length) {
    let selector = config.bindto;

    chart = c3.generate(config);

    setTitle(selector, config.data);
  }
  return chart;
}

function setTitle(selector, data) {
  let max = getMax(data.columns);
  let total = getTotal(data.columns);

  if (total) {
    let title = _.round(100 * max[1] / total, 1).toString() + '%';

    $().pfSetDonutChartTitle(selector, title, data.names[max[0]]);
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
