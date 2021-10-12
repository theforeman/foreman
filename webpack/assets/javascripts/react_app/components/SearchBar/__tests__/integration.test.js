import React from 'react';
import { KEYCODES } from '../../../common/keyCodes';
import API from '../../../redux/API/API';
import IntegrationTestHelper from '../../../common/IntegrationTestHelper';
import { SearchBarProps } from '../SearchBar.fixtures';
import SearchBar from '../index';
import { reducers } from '../../AutoComplete';
import bookmarksReducer from '../../PF4/Bookmarks/BookmarksReducer';
import foremanModalsReducer from '../../ForemanModal/ForemanModalReducer';
import { APIMiddleware, reducers as APIreducers } from '../../../redux/API';
import { visit } from '../../../../foreman_navigation';

jest.mock('../../../redux/API/API');
jest.mock('lodash/debounce', () => jest.fn(fn => fn));

const combinedReducers = {
  ...reducers,
  ...APIreducers,
  bookmarksPF4: bookmarksReducer,
  foremanModals: foremanModalsReducer,
};

describe('SearchBar integration test', () => {
  it('should flow', async () => {
    const label = 'result';
    API.get.mockImplementation(async () => ({
      data: [{ label, category: '' }],
    }));
    const integrationTestHelper = new IntegrationTestHelper(combinedReducers, [
      APIMiddleware,
    ]);
    const wrapper = integrationTestHelper.mount(
      <SearchBar {...SearchBarProps} />
    );
    const autocomplete = wrapper.find('AutoComplete').instance();
    autocomplete.handleInputChange(label);
    // trigger search button click.
    wrapper
      .find('.autocomplete-search-btn')
      .first()
      .simulate('click');
    expect(visit).toHaveBeenCalledTimes(1);
    const event = new KeyboardEvent('keypress', { charCode: KEYCODES.ENTER });
    global.dispatchEvent(event);
    expect(visit).toHaveBeenCalledTimes(2);
    // bookmark this page:
    // click on bookmark button
    wrapper
      .find('button[title="Bookmarks"]')
      .first()
      .simulate('click');
    integrationTestHelper.takeStoreAndLastActionSnapshot(
      'bookmarks button click'
    );
    // dropdown should open, lets click on 'Bookmark this page'
    wrapper
      .find('li[id="newBookmark"] > a')
      .first()
      .simulate('click');
    integrationTestHelper.takeActionsSnapshot(
      'in bookmarks dropdown: click on "bookmark this page"'
    );
    // modal should open, lets check its query value
    expect(wrapper.find('textarea[name="query"]').props().value).toBe(label);
  });
});
