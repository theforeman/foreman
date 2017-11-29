import toJson from 'enzyme-to-json';
import { mount } from 'enzyme';
import React from 'react';
import { Provider } from 'react-redux';
import thunk from 'redux-thunk';
import configureMockStore from 'redux-mock-store';
import BookmarksContainer from './';
import { initialState, afterSuccess } from './bookmarks.fixtures';

const mockStore = configureMockStore([thunk]);

function setup() {
  const props = {
    data: {
      controller: 'hosts',
      url: '/api/bookmarks',
      canCreate: true,
    },
  };

  const wrapper = mount(<Provider store={mockStore(initialState)}>
      <BookmarksContainer {...props} />
    </Provider>);

  return {
    props,
    wrapper,
  };
}

describe('bookmarks', () => {
  it('empty state', () => {
    const { wrapper } = setup();

    expect(toJson(wrapper)).toMatchSnapshot();
  });
  it('should include existing bookmarks for the current controller', () => {
    const wrapper = mount(<Provider store={mockStore(afterSuccess)}>
        <BookmarksContainer {...setup().props} />
      </Provider>);

    expect(toJson(wrapper)).toMatchSnapshot();
  });
  it('should not allow creating a new bookmark for users who dont have permission', () => {
    const { props } = setup();

    props.canCreate = false;

    const wrapper = mount(<Provider store={mockStore(afterSuccess)}>
        <BookmarksContainer {...props} />
      </Provider>);

    expect(toJson(wrapper)).toMatchSnapshot();
  });
  it('should hide the modal form intiailly', () => {
    const { wrapper } = setup();

    expect(wrapper.find('BookmarkContainer').props().showModal).toBe(false);
  });
  xit('should open the modal form for new bookmark', () => {
    const { wrapper } = setup();

    expect(wrapper.find('BookmarkContainer').props().showModal).toBe(false);
    wrapper.find('a #newBookmark').simulate('click');
    expect(wrapper.find('BookmarkContainer').props().showModal).toBe(true);
    // TODO: look at alternative solution at https://github.com/airbnb/enzyme/issues/252#issuecomment-266125422
  });
  xit('full flow', () => {
    const { wrapper } = setup();

    expect(wrapper.find('Bookmark').length).toEqual(0);
    wrapper.find('a #newBookmark').simulate('click');

    const formWrapper = wrapper.find('SearchModal');

    formWrapper.find('input [name="name"]').simulate('change', { target: { value: 'Joe.D' } });
    formWrapper.find('textarea [name="query"]').simulate('change', { target: { value: 'search' } });
    formWrapper.find('input [name="publik"]').simulate('change', { target: { value: false } });

    formWrapper.find('form').simulate('submit');
    expect(wrapper.find('Bookmark').length).toEqual(1);
  });
});
