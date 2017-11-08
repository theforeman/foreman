// Configure Enzyme
import Adapter from 'enzyme-adapter-react-16';
import { configure, shallow } from 'enzyme';
import React from 'react';

import Icon from './';

configure({ adapter: new Adapter() });

jest.unmock('./');

describe('Icon', () => {
  it('displays icon css', () => {
    const wrapper = shallow(<Icon type="ok" />);

    expect(wrapper.html()).toEqual('<span class="pficon pficon-ok"></span>');
  });
  it('can receive additionl css classes', () => {
    const wrapper = shallow(<Icon type="ok" className="pull-left" />);

    expect(wrapper.html()).toEqual('<span class="pficon pficon-ok pull-left"></span>');
  });
});
