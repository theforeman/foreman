import createLogger from 'redux-logger';
import thunk from 'redux-thunk';
import { applyMiddleware } from 'redux';
import { createInjectStore } from 'redux-injector';
import rootState from './reducers';

let middleware = [thunk];

if (process.env.NODE_ENV !== 'production' && !global.__testing__) {
  middleware = [...middleware, createLogger()];
}

const _getStore = () => createInjectStore(
  rootState,
  window.__REDUX_DEVTOOLS_EXTENSION__ && window.__REDUX_DEVTOOLS_EXTENSION__(),
  applyMiddleware(...middleware),
);

export default _getStore();

export const getStore = _getStore;
