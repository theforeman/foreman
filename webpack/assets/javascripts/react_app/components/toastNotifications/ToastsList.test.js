jest.unmock('./');

import React from 'react';
import { mount } from 'enzyme';
import ToastList from './';
import thunk from 'redux-thunk';
import configureMockStore from 'redux-mock-store';
import {
  initialState,
  emptyHtml,
  singleMessageState,
  singleMessageWithLinkState
} from './ToastList.fixtures';
const mockStore = configureMockStore([thunk]);

describe('ToastList', () => {
  it('emptyState', () => {
    const store = mockStore(initialState);
    const box = mount(<ToastList store={store} />);

    expect(box.render().html()).toBe(emptyHtml);
  });

  it('single message state', () => {
    const store = mockStore(singleMessageState);
    const box = mount(<ToastList store={store} />);

    expect(box.render().find('.alert').length).toBe(1);
  });

  it('single message state with link', () => {
    const store = mockStore(singleMessageWithLinkState);
    const box = mount(<ToastList store={store} />);

    expect(box.render().find('a').attr('href')).toBe('google.com');
  });
});
