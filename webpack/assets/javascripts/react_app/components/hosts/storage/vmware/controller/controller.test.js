// Configure Enzyme
import Adapter from 'enzyme-adapter-react-16';
import toJson from 'enzyme-to-json';
import { configure, shallow } from 'enzyme';
import React from 'react';

import { props } from './controller.fixtures';

import Controller from './';

configure({ adapter: new Adapter() });

let wrapper = null;

describe('StorageContainer', () => {
  beforeAll(() => {
    global.__ = str => str;
  });

  beforeEach(() => {
    wrapper = shallow(<Controller {...props} />);
  });

  it('should render controller', () => {
    expect(toJson(wrapper)).toMatchSnapshot();
  });
});
