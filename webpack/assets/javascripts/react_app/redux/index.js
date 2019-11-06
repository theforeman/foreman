import createLogger from 'redux-logger';
import thunk from 'redux-thunk';
import { applyMiddleware, createStore, compose } from 'redux';

import reducers from './reducers';

import { IntervalMiddleware, APIMiddleware } from './middlewares';

let middleware = [thunk, APIMiddleware, IntervalMiddleware];

const useLogger = () => {
  const isProduction = process.env.NODE_ENV === 'production';
  const isLogger = process.env.REDUX_LOGGER;

  if (!isProduction && !global.__testing__) {
    if (isLogger === undefined || isLogger === true) return true;
  }
  return isProduction && isLogger;
};

if (useLogger()) middleware = [...middleware, createLogger()];

const composeEnhancers = window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose;

export const generateStore = () =>
  createStore(reducers, composeEnhancers(applyMiddleware(...middleware)));

const store = generateStore();

export default store;
