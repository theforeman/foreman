// Configure Enzyme
import Adapter from 'enzyme-adapter-react-16';
import toJson from 'enzyme-to-json';
import { configure, shallow } from 'enzyme';
import React from 'react';

import Actions from './Actions';

configure({ adapter: new Adapter() });

describe('actions', () => {
  beforeEach(() => {
    global.__ = str => str;
  });

  it('should include a cancel / submit buttons', () => {
    const wrapper = shallow(<Actions />);

    expect(toJson(wrapper)).toMatchSnapshot();
  });
  it('buttons could be disabled', () => {
    const wrapper = shallow(<Actions disabled />);

    expect(toJson(wrapper)).toMatchSnapshot();
  });
  it('should show a spinner when submitting', () => {
    const wrapper = shallow(<Actions submitting />);

    expect(toJson(wrapper)).toMatchSnapshot();
  });
});
