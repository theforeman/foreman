import { combineReducers } from 'redux';
import interfaces from './interfaces';
import storage from './storage';
import powerStatus from './powerStatus';

export default combineReducers({
  interfaces,
  storage,
  powerStatus,
});
