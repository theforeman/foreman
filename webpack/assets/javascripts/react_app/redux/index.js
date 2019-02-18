import createLogger from '@theforeman/vendor/redux-logger';
import thunk from '@theforeman/vendor/redux-thunk';
import { applyMiddleware, createStore } from '@theforeman/vendor/redux';

import reducers from './reducers';

let middleware = [thunk];

if (process.env.NODE_ENV !== 'production' && !global.__testing__) {
  middleware = [...middleware, createLogger()];
}

export const generateStore = () =>
  createStore(
    reducers,
    window.__REDUX_DEVTOOLS_EXTENSION__ &&
      window.__REDUX_DEVTOOLS_EXTENSION__(),
    applyMiddleware(...middleware)
  );

const store = generateStore();

export default store;
