import { applyMiddleware, combineReducers, createStore } from 'redux';
import thunk from 'redux-thunk';

export function flushAllPromises() {
  return new Promise(resolve => setTimeout(() => resolve(), 100));
}

export function setupIntegrationTest(reducers) {
  const dispatchSpy = jest.fn(() => ({}));
  const reducerSpy = (state, action) => dispatchSpy(action);
  const emptyStore = applyMiddleware(thunk)(createStore);
  const combinedReducers = combineReducers({
    reducerSpy,
    ...reducers,
  });
  const store = emptyStore(combinedReducers);

  return { store, dispatchSpy };
}
