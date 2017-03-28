import { combineReducers } from 'redux';
import statistics from './statistics';
import hosts from './hosts';
import toasts from './toasts';

export default combineReducers({
    statistics,
    hosts,
  toasts
});
