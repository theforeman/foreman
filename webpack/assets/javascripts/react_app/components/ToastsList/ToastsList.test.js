import { mount } from '@theforeman/test';
import React from 'react';
import configureMockStore from 'redux-mock-store';
import thunk from 'redux-thunk';

import {
  emptyState,
  singleMessageState,
  singleMessageWithLinkState,
  multipleMessagesState,
  errorMessageState,
  warnMessageState,
} from './ToastList.fixtures';

import ToastList from './';

jest.unmock('./');

const mockStore = configureMockStore([thunk]);

describe('ToastList', () => {
  const testToastListRenderWithState = ({ description, state }) => {
    it(description, () => {
      const store = mockStore(state);
      const box = mount(<ToastList store={store} />);

      expect(box).toMatchSnapshot();
    });
  };

  const statesToTest = {
    emptyState,
    singleMessageState,
    singleMessageWithLinkState,
    multipleMessagesState,
  };

  Object.keys(statesToTest)
    .map(key => ({
      description: `should render with ${key}`,
      state: statesToTest[key],
    }))
    .forEach(testToastListRenderWithState);

  it('Should show error for invalid type', () => {
    const mockError = jest.fn();
    // eslint-disable-next-line no-console
    console.error = mockError;
    const store = mockStore(errorMessageState);
    mount(<ToastList store={store} />);
    expect(mockError).toBeCalledWith(
      "Toast notification type 'random' is invalid. Please use one of the following types: error,warning,success,info"
    );
    // eslint-disable-next-line no-console
    console.error.mockRestore();
  });

  it('Should show warn for notice type', () => {
    const mockWarn = jest.fn();
    // eslint-disable-next-line no-console
    console.warn = mockWarn;
    const store = mockStore(warnMessageState);
    mount(<ToastList store={store} />);
    expect(mockWarn).toBeCalledWith(
      "Toast notification type 'notice' is invalid. Please use one of the following types: error,warning,success,info"
    );
    // eslint-disable-next-line no-console
    console.warn.mockRestore();
  });
});
