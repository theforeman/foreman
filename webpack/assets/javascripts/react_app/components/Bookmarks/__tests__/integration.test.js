import React from 'react';
import { IntegrationTestHelper } from '@theforeman/test';

import API from '../../../redux/API/API';
import { APIMiddleware } from '../../../redux/API';

import Bookmarks, { reducers as bookmarksReducer } from '../index';
import { reducers as autocompleteReducer } from '../../AutoComplete/index';
import foremanModalsReducer from '../../ForemanModal/ForemanModalReducer';
import {
  response,
  submitResponse,
  name,
  search,
  publik,
} from '../Bookmarks.fixtures';

const reducers = {
  foremanModals: foremanModalsReducer,
  ...bookmarksReducer,
  ...autocompleteReducer,
};

jest.mock('../../../redux/API/API');

const props = {
  canCreate: true,
  documentationUrl: '/docs',
  onBookmarkClick: jest.fn(),
  url: '/api/v2/hosts',
  controller: 'hosts',
};

describe('Bookmarks integration test', () => {
  it('should flow', async () => {
    API.get.mockImplementation(async () => response);

    const testHelper = new IntegrationTestHelper(reducers, [APIMiddleware]);
    const component = testHelper.mount(<Bookmarks {...props} />);
    testHelper.takeStoreSnapshot('initial state');

    const togglerButton = component.find('.dropdown-toggle .btn');

    togglerButton.simulate('click');
    testHelper.takeStoreAndLastActionSnapshot('bookmarks opened');

    expect(component.find('Spinner').exists()).toBeTruthy();
    expect(component.find('Bookmark').exists()).not.toBeTruthy();

    await IntegrationTestHelper.flushAllPromises();
    component.update();
    testHelper.takeStoreAndLastActionSnapshot('bookmarks opened and loaded');

    expect(component.find('Spinner').exists()).not.toBeTruthy();
    expect(component.find('Bookmark').exists()).toBeTruthy();
    expect(
      component.find(`a[href="${props.documentationUrl}"]`).exists()
    ).toBeTruthy();

    const newBookmark = component.find('a#newBookmark');
    newBookmark.simulate('click');
    testHelper.takeStoreAndLastActionSnapshot('modal opened');

    API.post.mockImplementation(async () => submitResponse);

    component
      .find('input[name="name"]')
      .simulate('change', { target: { name: 'name', value: name } });
    component
      .find('textarea[name="query"]')
      .simulate('change', { target: { name: 'query', value: search } });
    component
      .find('input[name="public"]')
      .simulate('change', { target: { name: 'public', value: publik } });

    component.find('form').simulate('submit');
    await IntegrationTestHelper.flushAllPromises();
    component.update();

    testHelper.takeStoreSnapshot('form submitted');
  });

  it('should not allow to create bookmarks when users do not have permission', () => {
    API.get.mockImplementation(async () => response);
    const testHelper = new IntegrationTestHelper(reducers);

    const component = testHelper.mount(
      <Bookmarks {...props} canCreate={false} />
    );

    const togglerButton = component.find('.dropdown-toggle .btn');

    togglerButton.simulate('click');
    expect(component.find('a#newBookmark').exists()).not.toBeTruthy();
  });
});
