import { apiRequest } from './APIRequest';
import { isAPIAction } from './APIHelpers';

export const APIMiddleware = store => next => action => {
  if (isAPIAction(action)) {
    if (!action?.payload?.key) {
      throw new Error(
        `API action ${action?.type} was dispatched without a key. API action payloads must have a key. Did you confuse default and named exports?`
      );
    }
    apiRequest(action, store);
  }
  return next(action);
};
