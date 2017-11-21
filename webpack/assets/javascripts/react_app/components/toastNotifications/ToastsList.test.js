import toJson from 'enzyme-to-json';
import { mount } from 'enzyme';
import React from 'react';
import configureMockStore from 'redux-mock-store';
import thunk from 'redux-thunk';

import {
  initialState,
  singleMessageState,
  singleMessageWithLinkState,
} from './ToastList.fixtures';

import ToastList from './';

jest.unmock('./');

const mockStore = configureMockStore([thunk]);

describe('ToastList', () => {
  it('emptyState', () => {
    const store = mockStore(initialState);
    const box = mount(<ToastList store={store} />);

    expect(toJson(box)).toMatchSnapshot();
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
