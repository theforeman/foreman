import { combineReducers } from 'redux';
import statistics from './statistics';
import hosts from './hosts';
import notifications from './notifications/';
import toasts from './toasts';

export default combineReducers({
  statistics,
  hosts,
  notifications,
  toasts,
});
