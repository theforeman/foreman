import store from '../index';
import { combineReducersAsync } from './index';

window.tfm_async_reducers = window.tfm_async_reducers || {};

export default (name, asyncReducer) => {
  const asyncReducers = window.tfm_async_reducers;

  asyncReducers[name] = asyncReducer;
  store.replaceReducer(combineReducersAsync(asyncReducers));
};
