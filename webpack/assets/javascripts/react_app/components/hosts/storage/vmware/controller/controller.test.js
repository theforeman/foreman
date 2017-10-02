// Configure Enzyme
import { configure } from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';
configure({ adapter: new Adapter() });

import React from 'react';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import { props } from './controller.fixtures';
import Controller from './';

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
