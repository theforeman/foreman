import createLogger from 'redux-logger';
import thunk from 'redux-thunk';
import { applyMiddleware, createStore } from 'redux';

import reducer from './reducers';

let middleware = [thunk];

if (process.env.NODE_ENV !== 'production' && !global.__testing__) {
  middleware = [...middleware, createLogger()];
}

const _getStore = () => createStore(
  reducer,
  window.__REDUX_DEVTOOLS_EXTENSION__ && window.__REDUX_DEVTOOLS_EXTENSION__(),
  applyMiddleware(...middleware),
);

export default _getStore();

export const getStore = _getStore;
