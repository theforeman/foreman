import { mount } from '@theforeman/test';
import React from 'react';
import configureMockStore from 'redux-mock-store';
import thunk from 'redux-thunk';

import {
  emptyState,
  singleMessageState,
  singleMessageWithLinkState,
  multipleMessagesState,
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
});
