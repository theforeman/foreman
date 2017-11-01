import storage from './storage';
import powerStatus from './powerStatus';
import { combineReducers } from 'redux';

export default combineReducers({
  storage,
  powerStatus,
});
