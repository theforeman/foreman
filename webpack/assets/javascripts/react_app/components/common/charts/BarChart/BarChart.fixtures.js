export const barChartData = {
  data: [
    ['Fedora 21', 3],
    ['Ubuntu 14.04', 4],
    ['Centos 7', 2],
    ['Debian 8', 1],
  ],
  xAxisLabel: 'OS',
  yAxisLabel: 'COUNT',
};

export const barChartConfig = {
  data: {
    columns: [['Number of Events', 3, 4, 2, 1]],
    type: 'bar',
  },
  color: {
    pattern: ['#0088ce', '#ec7a08', '#3f9c35', '#005c66', 'f9d67a', '#703fec'],
  },
  tooltip: {
    format: {},
  },
  legend: {
    show: true,
  },
  padding: null,
  size: {
    width: 240,
    height: 240,
  },
  id: 'operatingsystem',
  axis: {
    x: {
      categories: ['Fedora 21', 'Ubuntu 14.04', 'Centos 7', 'Debian 8'],
      type: 'category',
    },
  },
  categories: ['Fedora 21', 'Ubuntu 14.04', 'Centos 7', 'Debian 8'],
};

export const barChartConfigWithEmptyData = {
  ...barChartConfig,
  data: {
    columns: [],
    type: 'bar',
  },
};

export const emptyData = null;
