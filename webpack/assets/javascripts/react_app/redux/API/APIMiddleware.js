import { API_OPERATIONS, actionTypeGenerator } from './';
import { get } from './APIRequest';

export const APIMiddleware = store => next => action => {
  const { type, key, payload = {}, url, actionTypes = {} } = action;
  if (type === API_OPERATIONS.GET) {
    get(payload, url, store, actionTypeGenerator(key, actionTypes));
  }

  return next(action);
};
