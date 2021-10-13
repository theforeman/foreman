import { apiRequest } from './APIRequest';
import { isAPIAction } from './APIHelpers';

export const APIMiddleware = (store) => (next) => (action) => {
  if (isAPIAction(action)) {
    apiRequest(action, store);
  }
  return next(action);
};
