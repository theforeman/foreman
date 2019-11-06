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

const actions = {
  architectures: {
    REQUEST: {
      payload: payloads.architecture,
      type: 'STATISTICS_DATA_REQUEST',
    },
    SUCCESS: {
      payload: {
        data: [['x86_64', 6]],
        ...payloads.architecture,
      },
      type: 'STATISTICS_DATA_SUCCESS',
    },
    FAILURE: {
      payload: {
        error: new Error('Request failed with status code 422'),
        payload: payloads.architecture,
      },
      type: 'STATISTICS_DATA_FAILURE',
    },
    API_MIDDLEWARE: {
      key: 'STATISTICS_DATA',
      payload: payloads.architecture,
      type: 'API_GET',
      url: 'statistics/architecture',
    },
  },
  operatingsystem: {
    REQUEST: {
      payload: payloads.operatingsystem,
      type: 'STATISTICS_DATA_REQUEST',
    },
    SUCCESS: {
      payload: {
        data: [['centOS 7.1', 6]],
        ...payloads.operatingsystem,
      },
      type: 'STATISTICS_DATA_SUCCESS',
    },
    FAILURE: {
      payload: {
        error: new Error('Request failed with status code 422'),
        payload: payloads.operatingsystem,
      },
      type: 'STATISTICS_DATA_FAILURE',
    },
    API_MIDDLEWARE: {
      key: 'STATISTICS_DATA',
      payload: payloads.operatingsystem,
      type: 'API_GET',
      url: 'statistics/operatingsystem',
    },
  },
};

export const onSuccessActions = [
  actions.operatingsystem.REQUEST,
  actions.operatingsystem.API_MIDDLEWARE,
  actions.architectures.REQUEST,
  actions.architectures.API_MIDDLEWARE,
  actions.operatingsystem.SUCCESS,
  actions.architectures.SUCCESS,
];

export const onFailureActions = [
  actions.operatingsystem.REQUEST,
  actions.operatingsystem.API_MIDDLEWARE,
  actions.architectures.REQUEST,
  actions.architectures.API_MIDDLEWARE,
  actions.operatingsystem.FAILURE,
  actions.architectures.FAILURE,
];
