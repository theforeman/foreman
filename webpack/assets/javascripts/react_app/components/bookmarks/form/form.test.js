import toJson from 'enzyme-to-json';
import { mount } from 'enzyme';
import React from 'react';
import { Provider } from 'react-redux';
import BookmarkForm from './';
import { generateStore } from '../../../redux';
import * as FormActions from '../../../redux/actions/common/forms';
import API from '../../../API';

jest.mock('../../../API');
API.post = jest.fn(() => Promise.resolve({ id: 1 }));

function setup() {
  const props = {
    controller: 'hosts',
    url: '/api/bookmarks',
    onCancel: jest.fn(),
  };

  const wrapper = mount(<Provider store={generateStore()}>
      <BookmarkForm {...props} />
    </Provider>);

  return {
    props,
    wrapper,
  };
}

describe('bookmark form', () => {
  it('should include the correct initial values', () => {
    const { wrapper } = setup();

    expect(wrapper.find('BookmarkForm').props().initialValues).toEqual({
      publik: true,
      query: '',
    });
  });
  it('should render the entire form', () => {
    const { wrapper } = setup();

    expect(toJson(wrapper)).toMatchSnapshot();
  });
  it('should convert params for submittion correctly', () => {
    const spy = jest.spyOn(FormActions, 'submitForm');
    const { wrapper } = setup();

    wrapper.find('input[name="name"]').simulate('change', { target: { value: 'Joe' } });
    wrapper.find('textarea[name="query"]').simulate('change', { target: { value: 'search' } });
    wrapper.find('input[name="publik"]').simulate('change', { target: { value: true } });

    wrapper.find('form').simulate('submit');
    expect(wrapper.find('.spinner').length).toEqual(1);
    expect(spy).toHaveBeenCalledWith({
      item: 'Bookmark',
      url: '/api/bookmarks',
      values: {
        controller: 'hosts', name: 'Joe', public: true, query: 'search',
      },
    });
  });
  it('should allow creating a private bookmark', () => {
    const spy = jest.spyOn(FormActions, 'submitForm');
    const { wrapper } = setup();

    wrapper.find('input[name="name"]').simulate('change', { target: { value: 'Joe' } });
    wrapper.find('textarea[name="query"]').simulate('change', { target: { value: 'search' } });
    wrapper.find('input[name="publik"]').simulate('change', { target: { value: false } });

    wrapper.find('form').simulate('submit');
    expect(wrapper.find('.spinner').length).toEqual(1);
    expect(spy).toHaveBeenCalledWith({
      item: 'Bookmark',
      url: '/api/bookmarks',
      values: {
        controller: 'hosts', name: 'Joe', public: false, query: 'search',
      },
    });
    spy.mockReset();
    spy.mockRestore();
  });
  it('should not create an invalid bookmark', () => {
    const spy = jest.spyOn(FormActions, 'submitForm');
    const { wrapper } = setup();

    wrapper.find('form').simulate('submit');
    expect(wrapper.find('.spinner').length).toEqual(0);
    expect(spy).toHaveBeenCalledTimes(0);
    spy.mockReset();
    spy.mockRestore();
  });
  it('should allow creating a bookmark with a dot', () => {
    const spy = jest.spyOn(FormActions, 'submitForm');
    const { wrapper } = setup();

    wrapper.find('input[name="name"]').simulate('change', { target: { value: 'Joe.D' } });
    wrapper.find('textarea[name="query"]').simulate('change', { target: { value: 'search' } });
    wrapper.find('input[name="publik"]').simulate('change', { target: { value: false } });

    wrapper.find('form').simulate('submit');
    expect(wrapper.find('.spinner').length).toEqual(1);
    expect(spy).toHaveBeenCalledWith({
      item: 'Bookmark',
      url: '/api/bookmarks',
      values: {
        controller: 'hosts', name: 'Joe.D', public: false, query: 'search',
      },
    });
    spy.mockReset();
    spy.mockRestore();
  });
});
