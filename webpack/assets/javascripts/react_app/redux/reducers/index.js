import { combineReducers } from 'redux';
import statistics from './statistics';
import hosts from './hosts';
import notifications from './notifications/';
import toasts from './toasts';

export function combineReducersAsync(asyncReducers) {
  return combineReducers({
    statistics,
    hosts,
    notifications,
    toasts,
    ...asyncReducers,
  });
}

export default combineReducersAsync();
