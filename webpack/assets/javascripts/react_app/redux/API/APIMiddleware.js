import { API_OPERATIONS, actionTypeGenerator } from './';
import { get } from './APIRequest';
import { startInterval } from '../middlewares/IntervalMiddleware';

export const APIMiddleware = store => next => action => {
  const { type, key, payload = {}, url, actionTypes = {}, polling } = action;
  if (type === API_OPERATIONS.GET) {
    const APIActionTypes = actionTypeGenerator(key, actionTypes);
    const APIRequest = () => get(payload, url, store, APIActionTypes);
    if (polling) {
      return store.dispatch(startInterval(key, APIRequest, polling));
    }
    APIRequest();
  }
  return next(action);
};
