import toJson from 'enzyme-to-json';
import { render, mount } from 'enzyme';
import React from 'react';
import { Provider } from 'react-redux';
import thunk from 'redux-thunk';
import configureMockStore from 'redux-mock-store';
import { Dropdown } from 'patternfly-react';
import BookmarksContainer from './';
import API from '../../API';
import {
  initialState,
  afterSuccess,
  afterSuccessNoResults,
  afterRequest,
  afterError,
  bookmarks,
} from './bookmarks.fixtures';
import { onSuccessActions } from '../../redux/actions/bookmarks/bookmarks.fixtures';
import * as BookmarkActions from '../../redux/actions/bookmarks';
import { noop } from '../../common/helpers';

jest.mock('../../API');
API.get = jest.fn(() => Promise.resolve({ results: bookmarks }));
const mockStore = configureMockStore([thunk]);

function setup(state = initialState) {
  const props = {
    data: {
      controller: 'hosts',
      url: '/api/bookmarks',
      canCreate: true,
      documentationUrl: '',
    },
    onBookmarkClick: noop,
  };

  const component = (
    <Provider store={mockStore(state)}>
      <BookmarksContainer {...props} />
    </Provider>
  );

  return {
    props,
    component,
  };
}

describe('bookmarks loading', () => {
  const loadBookmarksScenario = ({ state, getBookmarksCalls }) => {
    jest.mock('../../redux/actions/bookmarks');
    BookmarkActions.getBookmarks = jest
      .fn()
      .mockReturnValue(onSuccessActions[1]);
    mount(setup(state).component)
      .find(Dropdown)
      .simulate('click');
    expect(BookmarkActions.getBookmarks.mock.calls).toHaveLength(
      getBookmarksCalls
    );
    jest.unmock('../../redux/actions/bookmarks');
  };

  const fixtures = {
    'initial state should call getBookmarks': {
      state: initialState,
      getBookmarksCalls: 1,
    },
    'after success state with 0 bookmarks should call getBookmarks': {
      state: afterSuccessNoResults,
      getBookmarksCalls: 1,
    },
    'after error state should call getBookmarks': {
      state: afterError,
      getBookmarksCalls: 1,
    },
    'after request state should not call getBookmarks': {
      state: afterRequest,
      getBookmarksCalls: 0,
    },
    'after success state with bookmarks should not call getBookmarks': {
      state: afterSuccess,
      getBookmarksCalls: 0,
    },
  };

  Object.keys(fixtures).forEach(testCase =>
    it(testCase, () => loadBookmarksScenario(fixtures[testCase]))
  );
});

describe('bookmarks', () => {
  it('empty state', () => {
    expect(toJson(render(setup().component))).toMatchSnapshot();
  });

  it('should show loading spinner when loading bookmarks', () => {
    const spinner = mount(setup(afterRequest).component).find('Spinner');
    expect(spinner).toHaveLength(1);
  });

  it('should show an error message if loading failed', () => {
    expect(toJson(render(setup(afterError).component))).toMatchSnapshot();
  });

  it('should show no bookmarks if server did not respond with any', () => {
    expect(
      toJson(render(setup(afterSuccessNoResults).component))
    ).toMatchSnapshot();
  });
  it('should include existing bookmarks for the current controller', () => {
    expect(mount(setup(afterSuccess).component).find('Bookmark')).toHaveLength(
      2
    );
  });
  it('should not allow creating a new bookmark for users who dont have permission', () => {
    const { props } = setup();

    props.canCreate = false;

    const wrapper = mount(
      <Provider store={mockStore(afterSuccess)}>
        <BookmarksContainer {...props} />
      </Provider>
    );

    expect(wrapper.find('MenuItem#newBookmarks')).toHaveLength(0);
  });
  it('should hide the modal form intiailly', () => {
    expect(
      mount(setup().component)
        .find('BookmarkContainer')
        .props().showModal
    ).toBe(false);
  });

  // eslint-disable-next-line jest/no-disabled-tests
  xit('should open the modal form for new bookmark', () => {
    const wrapper = mount(setup().component);
    expect(wrapper.find('BookmarkContainer').props().showModal).toBe(false);
    wrapper.find('a #newBookmark').simulate('click');
    expect(wrapper.find('BookmarkContainer').props().showModal).toBe(true);
    // TODO: look at alternative solution at https://github.com/airbnb/enzyme/issues/252#issuecomment-266125422
  });

  // eslint-disable-next-line jest/no-disabled-tests
  xit('full flow', () => {
    const wrapper = mount(setup().component);

    expect(wrapper.find('Bookmark')).toHaveLength(0);
    wrapper.find('a #newBookmark').simulate('click');

    const formWrapper = wrapper.find('SearchModal');

    formWrapper
      .find('input [name="name"]')
      .simulate('change', { target: { value: 'Joe.D' } });
    formWrapper
      .find('textarea [name="query"]')
      .simulate('change', { target: { value: 'search' } });
    formWrapper
      .find('input [name="publik"]')
      .simulate('change', { target: { value: false } });

    formWrapper.find('form').simulate('submit');
    expect(wrapper.find('Bookmark')).toHaveLength(1);
  });
});
