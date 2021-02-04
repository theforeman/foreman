import React from 'react';
import uuidV1 from 'uuid/v1';
import { IntegrationTestHelper } from '@theforeman/test';

import API from '../../../../../redux/API/API';
import { APIMiddleware } from '../../../../../redux/API';

import BookmarkForm from '../index';
import { reducers as bookmarksReducer } from '../../../index';
import { reducers as autocompleteReducer } from '../../../../AutoComplete/index';
import foremanModalsReducer from '../../../../ForemanModal/ForemanModalReducer';
import {
  response,
  name,
  search,
  publik,
  item,
  submitResponse,
  controller,
  bookmarks,
} from '../../../Bookmarks.fixtures';
import { BOOKMARKS_SUCCESS } from '../../../BookmarksConstants';

const reducers = {
  foremanModals: foremanModalsReducer,
  ...bookmarksReducer,
  ...autocompleteReducer,
};

jest.mock('../../../../../redux/API/API');
jest.mock('uuid/v1');
uuidV1.mockImplementation(() => '1547e1c0-309a-11e9-98f5-5f761412a4c2');

const props = {
  url: '/api/v2/hosts',
  controller: 'hosts',
  setModalClosed: jest.fn(),
};

describe('Bookmark form integration test', () => {
  it('should allow submission when fields filled in', async () => {
    API.post.mockImplementation(async () => submitResponse);

    const testHelper = new IntegrationTestHelper(reducers, [APIMiddleware]);
    testHelper.store.dispatch({
      type: BOOKMARKS_SUCCESS,
      payload: {
        controller,
        item,
      },
      response: response.data,
    });

    const component = testHelper.mount(<BookmarkForm {...props} />);

    expect(
      component.find('Button[bsStyle="primary"]').props().disabled
    ).toBeTruthy();
    expect(
      component.find('Button[bsStyle="default"]').props().disabled
    ).not.toBeTruthy();
    component
      .find('input[name="name"]')
      .simulate('change', { target: { name: 'name', value: name } });
    component
      .find('textarea[name="query"]')
      .simulate('change', { target: { name: 'query', value: search } });
    component
      .find('input[name="public"]')
      .simulate('change', { target: { name: 'public', value: publik } });

    const submitBtn = component.find('Button[bsStyle="primary"]');

    expect(submitBtn.disabled).not.toBeTruthy();
    expect(
      component.find('Button[bsStyle="default"]').props().disabled
    ).not.toBeTruthy();

    submitBtn.simulate('submit');
    await IntegrationTestHelper.flushAllPromises();
    component.update();

    testHelper.takeActionsSnapshot('form submitted');
  });

  it("should run with name validation", async () => {
    const testHelper = new IntegrationTestHelper(reducers, [APIMiddleware]);
    const component = testHelper.mount(<BookmarkForm {...props} bookmarks={bookmarks} />);
    component
    .find('input[name="name"]')
    .simulate('change', { target: { name: 'name', value: '1111' } });

    await IntegrationTestHelper.flushAllPromises();
    component.update();
    const formError = component.find('CommonForm[label="Name"]').prop('error');

    expect(formError).toBe('name already exists');

  })
});
