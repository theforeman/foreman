const WithDataProps = {
  config: {
    donut: {
      width: 15,
      label: {
        show: false,
      },
    },
    data: {
      type: 'donut',
      columns: [
        ['Fedora 21', 3],
        ['Ubuntu 14.04', 4],
        ['Centos 7', 2],
        ['Debian 8', 1],
      ],
      names: {
        'Fedora 21': 'Fedora 21',
        'Ubuntu 14.04': 'Ubuntu 14.04',
        'Centos 7': 'Centos 7',
        'Debian 8': 'Debian 8',
      },
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
    bindto: '#operatingsystemChart',
  },
  modalConfig: {
    donut: {
      width: 25,
      label: {
        show: false,
      },
    },
    data: {
      type: 'donut',
      columns: [
        ['Fedora 21', 3],
        ['Ubuntu 14.04', 4],
        ['Centos 7', 2],
        ['Debian 8', 1],
      ],
      names: {
        'Fedora 21': 'Fedora 21',
        'Ubuntu 14.04': 'Ubuntu 14.04',
        'Centos 7': 'Centos 7',
        'Debian 8': 'Debian 8',
      },
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
    size: {
      height: 500,
    },
  },
  noDataMsg: 'No data available',
  tip: 'Expand the chart',
  status: 'RESOLVED',
  id: 'operatingsystem',
  title: 'OS Distribution',
  search: '/hosts?search=os_title=~VAL~',
};

export default WithDataProps;
