export const requestData = [
  {
    id: 'operatingsystem',
    title: 'OS Distribution',
    url: 'statistics/operatingsystem',
    search: '/hosts?search=os_title=~VAL~',
  },
  {
    id: 'architecture',
    title: 'Architecture Distribution',
    url: 'statistics/architecture',
    search: '/hosts?search=facts.architecture=~VAL~',
  },
];

export const onFailureActions = [
  {
    payload: {
      id: 'operatingsystem',
      search: '/hosts?search=os_title=~VAL~',
      title: 'OS Distribution',
      url: 'statistics/operatingsystem',
    },
    type: 'STATISTICS_DATA_REQUEST',
  },
  {
    payload: {
      error: {},
      item: {
        id: 'operatingsystem',
        search: '/hosts?search=os_title=~VAL~',
        title: 'OS Distribution',
        url: 'statistics/operatingsystem',
      },
    },
    type: 'STATISTICS_DATA_FAILURE',
  },
  {
    payload: {
      id: 'architecture',
      search: '/hosts?search=facts.architecture=~VAL~',
      title: 'Architecture Distribution',
      url: 'statistics/architecture',
    },
    type: 'STATISTICS_DATA_REQUEST',
  },
  {
    payload: {
      error: {},
      item: {
        id: 'architecture',
        search: '/hosts?search=facts.architecture=~VAL~',
        title: 'Architecture Distribution',
        url: 'statistics/architecture',
      },
    },
    type: 'STATISTICS_DATA_FAILURE',
  },
];
