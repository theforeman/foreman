import toJson from 'enzyme-to-json';
import { mount } from 'enzyme';
import React from 'react';
import Bookmark from './Bookmark';

function setup() {
  const props = {
    text: 'label',
    query: 'query',
    onClick: jest.fn(),
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
};

describe('bookmark', () => {
  it('should create a link to a bookmark', () => {
    setupTurbolinksMock();
    const { props, wrapper } = setup();

    expect(toJson(wrapper)).toMatchSnapshot();
    wrapper.find('a').simulate('click');
    expect(props.onClick).toBeCalled();
  });
});
