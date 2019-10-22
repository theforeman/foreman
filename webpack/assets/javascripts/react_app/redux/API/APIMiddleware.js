/* eslint-disable no-console */
import { API_OPERATIONS, actionTypeGenerator } from './';
import { get } from './APIRequest';
import { startPolling } from './APIActions';
import { selectPollingID } from './APISelectors';
import { registeredPollingException } from './APIHelpers';

export const APIMiddleware = store => next => action => {
  const { type, key, payload = {}, url, actionTypes = {}, polling } = action;
  if (type === API_OPERATIONS.GET) {
    const APIRequest = () =>
      get(payload, url, store, actionTypeGenerator(key, actionTypes));
    if (polling) {
      const isAlreadyPolling = selectPollingID(store.getState(), key);
      if (isAlreadyPolling) {
        console.error(registeredPollingException(key));
        return next(action);
      }
      /** 
        force the APIRequest for the first time,
        instead of waiting for the polling to start.
      */
      APIRequest();
      return next(startPolling(key, APIRequest, polling));
    }
    APIRequest();
  }
  return next(action);
};
