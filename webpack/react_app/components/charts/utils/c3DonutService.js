import $ from 'jquery';

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
  enums: enums
};

function getDonutConfig() {

  let config = {
    donut: {
      width: enums.WIDTH.SMALL,
      label: { show: false }
    },
    data: {
      type: 'donut',
      columns: []
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

  return config;
}

function getLargeDonutConfig() {
  let config = getDonutConfig();

  config.size = enums.SIZE.LARGE;
  config.donut.width = enums.WIDTH.LARGE;

  return config;
}
