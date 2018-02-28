export default [['column1', 100], ['column2', 50]];

export const mockStoryData = {
  donut: {
    width: 15,
    label: {
      show: false,
    },
  },
  data: {
    columns: [['Fedora 21', 3], ['Ubuntu 14.04', 4], ['Centos 7', 2], ['Debian 8', 1]],
  },
  tooltip: {
    show: true,
  },
  legend: {
    show: false,
  },
  padding: {
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
  },
  noDataMsg: 'No data available',
  tip: 'Expand the chart',
  status: 'RESOLVED',
  id: 'operatingsystem',
  title: 'OS Distribution',
  search: '/hosts?search=os_title=~VAL~',
};

export const emptyData = {
  data: {
    type: 'donut',
    columns: [],
    names: {
    },
  },
  noDataMsg: 'No data available',
};

export const zeroedData = [
  ['Fedora 21', 0],
  ['Ubuntu 14.04', 0],
  ['Centos 7', 0],
  ['Debian 8', 0],
];

export const mixedData = [
  ['Fedora 21', 3],
  ['Ubuntu 14.04', 2],
  ['Centos 7', 0],
  ['Debian 8', 0],
];
