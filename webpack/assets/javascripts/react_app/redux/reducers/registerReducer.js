import forceSingleton from '../../common/forceSingleton';
import store from '../index';
import { combineReducersAsync } from './index';

const asyncReducers = forceSingleton('async_reducers', () => ({}));

export default (name, asyncReducer) => {
  asyncReducers[name] = asyncReducer;
  store.replaceReducer(combineReducersAsync(asyncReducers));
};
