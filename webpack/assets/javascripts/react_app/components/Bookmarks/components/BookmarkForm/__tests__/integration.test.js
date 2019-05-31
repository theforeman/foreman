import React from 'react';
import { IntegrationTestHelper } from 'react-redux-test-utils';

import API from '../../../../../API';

import BookmarkForm from '../index';
import { reducers } from '../../../index';

import {
  response,
  name,
  search,
  publik,
  item,
  submitResponse,
} from '../../../Bookmarks.fixtures';
import { BOOKMARKS_SUCCESS } from '../../../BookmarksConstants';

jest.mock('../../../../../API');

const props = {
  url: '/api/v2/hosts',
  controller: 'hosts',
};

describe('Bookmark form integration test', () => {
  it('should allow submission when fields filled in', async () => {
    const testHelper = new IntegrationTestHelper(reducers);
    testHelper.store.dispatch({
      type: BOOKMARKS_SUCCESS,
      payload: { ...response.data, item },
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

    const mock = jest.fn();

    API.post.mockImplementation(async (...args) => {
      mock(...args);
      return submitResponse;
    });

    submitBtn.simulate('submit');
    await IntegrationTestHelper.flushAllPromises();
    component.update();

    expect(mock).toHaveBeenCalledWith(props.url, submitResponse.data);
  });
});
