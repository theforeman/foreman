import { STATUS } from '../../constants';

export const selectAPI = state => state.API;

export const selectAPIByKey = (state, key) => selectAPI(state)[key] || {};

export const selectAPIStatus = (state, key) =>
  selectAPIByKey(state, key).status;

export const selectAPIPayload = (state, key) =>
  selectAPIByKey(state, key).payload || {};

export const selectAPIResponse = (state, key) =>
  selectAPIByKey(state, key).response || {};

export const selectAPIError = (state, key) =>
  selectAPIStatus(state, key) === STATUS.ERROR
    ? selectAPIResponse(state, key)
    : null;

export const selectAPIErrorMessage = (state, key) => {
  const error = selectAPIError(state, key);
  return error && error.message;
};

export const selectAPITimestamp = (state, key) =>
  selectAPIPayload(state, key)?.timestamp;
