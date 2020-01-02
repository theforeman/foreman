import { API_OPERATIONS } from './';
import { get } from './APIRequest';

export const APIMiddleware = store => next => action => {
  const { type, payload } = action;
  if (type === API_OPERATIONS.GET) {
    get(payload, store);
  }

  return next(action);
};
