import React from 'react';
import { renderHook } from '@testing-library/react-hooks';
import { createStore, applyMiddleware } from 'redux';
import { Provider } from 'react-redux';
import { middlewares } from '../../redux/middlewares';
import reducers from '../../redux/reducers';

export const renderHookWithRedux = (callback, options) => {
  const store = createStore(reducers, applyMiddleware(...middlewares));
  const wrapper = ({ children }) => (
    <Provider store={store}>{children}</Provider>
  );
  return renderHook(callback, { wrapper, ...options });
};
