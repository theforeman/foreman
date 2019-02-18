import { combineReducers } from '@theforeman/vendor/redux';
import storage from './storage';
import powerStatus from './powerStatus';

export default combineReducers({
  storage,
  powerStatus,
});
