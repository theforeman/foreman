const payloads = {
  operatingsystem: {
    id: 'operatingsystem',
    search: '/hosts?search=os_title=~VAL~',
    title: 'OS Distribution',
    url: 'statistics/operatingsystem',
  },
  architecture: {
    id: 'architecture',
    title: 'Architecture Distribution',
    url: 'statistics/architecture',
    search: '/hosts?search=facts.architecture=~VAL~',
  },
};

export const failedRequestData = [
  payloads.operatingsystem,
  payloads.architecture,
];

export const successRequestData = [
  payloads.operatingsystem,
  payloads.architecture,
];

export const onSuccessActions = [
  {
    payload: payloads.operatingsystem,
    type: 'STATISTICS_DATA_REQUEST',
  },
  {
    key: 'STATISTICS_DATA',
    payload: payloads.operatingsystem,
    type: 'API_GET',
    url: 'statistics/operatingsystem',
  },
  {
    payload: payloads.architecture,
    type: 'STATISTICS_DATA_REQUEST',
  },
  {
    key: 'STATISTICS_DATA',
    payload: payloads.architecture,
    type: 'API_GET',
    url: 'statistics/architecture',
  },
  {
    payload: {
      data: [['centOS 7.1', 6]],
      ...payloads.operatingsystem,
    },
    type: 'STATISTICS_DATA_SUCCESS',
  },
  {
    payload: {
      data: [['x86_64', 6]],
      ...payloads.architecture,
    },
    type: 'STATISTICS_DATA_SUCCESS',
  },
];

export const onFailureActions = [
  {
    payload: payloads.operatingsystem,
    type: 'STATISTICS_DATA_REQUEST',
  },
  {
    key: 'STATISTICS_DATA',
    payload: payloads.operatingsystem,
    type: 'API_GET',
    url: 'statistics/operatingsystem',
  },
  {
    payload: payloads.architecture,
    type: 'STATISTICS_DATA_REQUEST',
  },
  {
    key: 'STATISTICS_DATA',
    payload: payloads.architecture,
    type: 'API_GET',
    url: 'statistics/architecture',
  },
  {
    payload: {
      error: new Error('Request failed with status code 422'),
      ...payloads.operatingsystem,
    },
    type: 'STATISTICS_DATA_FAILURE',
  },
  {
    payload: {
      error: new Error('Request failed with status code 422'),
      ...payloads.architecture,
    },
    type: 'STATISTICS_DATA_FAILURE',
  },
];
