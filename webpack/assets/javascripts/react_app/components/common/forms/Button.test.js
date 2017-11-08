// Configure Enzyme
import Adapter from 'enzyme-adapter-react-16';
import toJson from 'enzyme-to-json';
import { configure, shallow } from 'enzyme';
import React from 'react';

import Button from './Button';

configure({ adapter: new Adapter() });

describe('buttons', () => {
  it('should default to button type', () => {
    const wrapper = shallow(<Button />);

    expect(toJson(wrapper)).toMatchSnapshot();
  });
  it('should accept other button types', () => {
    const wrapper = shallow(<Button type="submit" />);

    expect(toJson(wrapper)).toMatchSnapshot();
  });
});
