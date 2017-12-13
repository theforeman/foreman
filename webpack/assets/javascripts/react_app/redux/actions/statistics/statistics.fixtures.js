export const failedRequestData = [
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

export const successRequestData = [
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

export const onSuccessActions = [
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
      id: 'architecture',
      search: '/hosts?search=facts.architecture=~VAL~',
      title: 'Architecture Distribution',
      url: 'statistics/architecture',
    },
    type: 'STATISTICS_DATA_REQUEST',
  },
  {
    payload: {
      data: [['centOS 7.1', 6]],
      id: 'operatingsystem',
      search: '/hosts?search=os_title=~VAL~',
      title: 'OS Distribution',
      url: 'statistics/operatingsystem',
    },
    type: 'STATISTICS_DATA_SUCCESS',
  },
  {
    payload: {
      data: [['x86_64', 6]],
      id: 'architecture',
      search: '/hosts?search=facts.architecture=~VAL~',
      title: 'Architecture Distribution',
      url: 'statistics/architecture',
    },
    type: 'STATISTICS_DATA_SUCCESS',
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
      id: 'architecture',
      search: '/hosts?search=facts.architecture=~VAL~',
      title: 'Architecture Distribution',
      url: 'statistics/architecture',
    },
    type: 'STATISTICS_DATA_REQUEST',
  },
  {
    payload: {
      error: new Error('Request failed with status code 422'),
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
      error: new Error('Request failed with status code 422'),
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
