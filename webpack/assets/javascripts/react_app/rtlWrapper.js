// For react-testing-library helpers, overrides, and utilities
// All elements from react-testing-library can be imported from this wrapper.
// See https://testing-library.com/docs/react-testing-library/setup for more info
import React from 'react';
import { getForemanContext } from './Root/Context/ForemanContext';
import { APIMiddleware } from './redux/API';
import thunk from 'redux-thunk';
import Immutable from 'seamless-immutable';
import { STATUS } from './constants';
import { render, waitFor } from '@testing-library/react';
import { createStore, applyMiddleware, combineReducers } from 'redux';
import { Provider } from 'react-redux';
import { MemoryRouter } from 'react-router-dom';
import { combineReducersAsync, allReducers } from './redux/reducers';

// Layout uses foreman_navigation which causes problems by importing the store
jest.mock('./components/Layout');

// r-t-lib's print limit for debug() is quite small, setting it to a much higher char max here.
// See https://github.com/testing-library/react-testing-library/issues/503 for more info.
process.env.DEBUG_PRINT_LIMIT = 99999;

const defaultContext = {
  currentUser: { login: 'admin', admin: true },
  toasts: [],
  metadata: {
    version: 'X.Y',
    docUrl: 'http://localhost/links/manual',
    UISettings: {
      perPage: 20,
      perPageOptions: [5, 10, 15, 20, 25, 50],
    },
  },
};

// Renders testable component with redux and react-router according to Katello's usage
// This should be used when you want a fully connected component with Redux state and actions.
function renderWithRedux(
  component,
  {
    apiNamespace, // namespace if using API middleware
    initialApiState = { response: {}, status: STATUS.PENDING }, // Default state for API middleware
    initialState = {}, // Override full state
    contextData = defaultContext, // Set initial ForemanContext values
  } = {},
) {
  // Namespacing the initial state as well
  const initialFullState = Immutable({
    API: {
      [apiNamespace]: initialApiState,
    },
    ...initialState,
  });
  // const middlewares = applyMiddleware(thunk, APIMiddleware);
  const store = createStore(combineReducers(allReducers), Immutable({}));

  const ForemanContext = getForemanContext(contextData);

  const connectedComponent = (
    <ForemanContext.Provider value={contextData}>
      <Provider store={store}>
        <MemoryRouter>{component}</MemoryRouter>
      </Provider>
    </ForemanContext.Provider>
  );

  return { ...render(connectedComponent), store };
}

// When the tests run slower, they can hit the default waitFor timeout, which is 1000ms
// There doesn't seem to be a way to set it globally for r-t-lib, so using this wrapper function
export const patientlyWaitFor = waitForFunc => waitFor(waitForFunc, { timeout: 5000 });

// re-export everything, so the library can be used from this wrapper.
export * from '@testing-library/react';
export * from '@testing-library/jest-dom';

export { renderWithRedux };
