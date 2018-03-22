import { combineReducers } from 'redux';
import storage from './storage';
import powerStatus from './powerStatus';

export default combineReducers({
  storage,
  powerStatus,
});
