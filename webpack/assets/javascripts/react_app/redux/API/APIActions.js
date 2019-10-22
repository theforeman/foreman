import { API_OPERATIONS } from './APIConstants';

export const stopPolling = key => ({
  type: API_OPERATIONS.STOP_POLLING,
  key,
});

export const startPolling = (key, APIRequest, polling) => ({
  type: API_OPERATIONS.START_POLLING,
  key,
  payload: {
    APIRequest,
    polling,
  },
});

export default {
  startPolling,
  stopPolling,
};
