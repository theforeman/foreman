import React from 'react';
import { KEYCODES } from '../../../common/keyCodes';
import API from '../../../redux/API/API';
import IntegrationTestHelper from '../../../common/IntegrationTestHelper';
import { SearchBarProps } from '../SearchBar.fixtures';
import SearchBar from '../index';
import { reducers } from '../../AutoComplete';
import bookmarksReducer from '../../../redux/reducers/bookmarks';
import { APIMiddleware } from '../../../redux/API';

jest.mock('../../../redux/API/API');
jest.mock('lodash/debounce', () => jest.fn(fn => fn));
global.Turbolinks = {
  visit: jest.fn(),
};

const combinedReducers = { ...reducers, bookmarks: bookmarksReducer };

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
    // expect it to call Turbolinks.
    expect(global.Turbolinks.visit.mock.calls).toHaveLength(1);
    const event = new KeyboardEvent('keypress', { charCode: KEYCODES.ENTER });
    global.dispatchEvent(event);
    expect(global.Turbolinks.visit.mock.calls).toHaveLength(2);
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
      .find('a[id="newBookmark"]')
      .first()
      .simulate('click');
    integrationTestHelper.takeStoreAndLastActionSnapshot(
      'in bookmarks dropdown: click on "bookmark this page"'
    );
    // modal should open, lets check its query value
    expect(
      wrapper
        .find('ConnectedField')
        .at(1)
        .props().initial
    ).toBe(label);
  });
});
