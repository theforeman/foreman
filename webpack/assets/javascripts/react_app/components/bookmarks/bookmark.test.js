import toJson from 'enzyme-to-json';
import { mount } from 'enzyme';
import React from 'react';
import Bookmark from './Bookmark';

function setup() {
  const props = {
    text: 'label',
    query: 'query',
  };

  const wrapper = mount(<Bookmark {...props} />);

  return {
    props,
    wrapper,
  };
}

const setupTurbolinksMock = () => {
  global.Turbolinks = {
    visit: jest.fn(),
  };
  Object.defineProperty(window.location, 'href', {
    writable: true,
    value: 'http://localhost',
  });
};

describe('bookmark', () => {
  it('should create a link to a bookmark', () => {
    setupTurbolinksMock();
    const { wrapper } = setup();

    expect(toJson(wrapper)).toMatchSnapshot();
    wrapper.find('a').simulate('click');
    expect(global.Turbolinks.visit).toBeCalled();
    expect(global.Turbolinks.visit).toHaveBeenLastCalledWith('http://localhost/?search=query');
  });
});
