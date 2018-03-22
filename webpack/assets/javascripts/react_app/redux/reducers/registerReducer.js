import store from '../index';
import { combineReducersAsync } from './index';

const asyncReducers = {};

export default (name, asyncReducer) => {
  asyncReducers[name] = asyncReducer;
  store.replaceReducer(combineReducersAsync(asyncReducers));
};
