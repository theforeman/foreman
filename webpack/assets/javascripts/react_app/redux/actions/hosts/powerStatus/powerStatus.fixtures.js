const mockSuccessRequests = [
  {
    path: '/hosts/:id/power',
    searchRegex: '/hosts/1/power',
    response: {
      id: 1,
      state: 'na',
      title: 'N/A',
    },
  },
];

export const requestData = {
  failRequest: { id: 0, url: '/hosts/0/power' },
  successRequest: { id: 1, url: '/hosts/1/power' },
};

export const onFailureActions = [
  { payload: { id: 0 }, type: 'HOST_POWER_STATUS_REQUEST' },
  {
    key: 'HOST_POWER_STATUS',
    payload: { id: 0 },
    type: 'API_GET',
    url: '/hosts/0/power',
  },
  {
    payload: {
      error: new Error('Request failed with status code 500'),
      id: 0,
    },
    type: 'HOST_POWER_STATUS_FAILURE',
  },
];

export const onSuccessActions = [
  { payload: { id: 1 }, type: 'HOST_POWER_STATUS_REQUEST' },
  {
    key: 'HOST_POWER_STATUS',
    payload: { id: 1 },
    type: 'API_GET',
    url: '/hosts/1/power',
  },
  {
    payload: mockSuccessRequests[0].response,
    type: 'HOST_POWER_STATUS_SUCCESS',
  },
];
