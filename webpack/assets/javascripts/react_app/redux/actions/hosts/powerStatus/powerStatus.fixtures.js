export const requestData = { id: 1, url: 'test' };

export const onFailureActions = [
  { payload: { id: 1 }, type: 'HOST_POWER_STATUS_REQUEST' },
  {
    payload: { error: {}, item: { id: 1 } },
    type: 'HOST_POWER_STATUS_FAILURE',
  },
];
