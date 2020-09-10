import { applyMiddleware, createStore, compose } from 'redux';
import forceSingleton from '../common/forceSingleton';

import reducers from './reducers';
import { middlewares } from './middlewares';

const composeEnhancers = window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose;

export const generateStore = () =>
  createStore(reducers, composeEnhancers(applyMiddleware(...middlewares)));

const store = forceSingleton('redux_store', generateStore);

export default store;
