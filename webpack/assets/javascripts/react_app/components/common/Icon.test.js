jest.unmock('./Icon');

import React from 'react';
import { shallow } from 'enzyme';
import Icon from './Icon';

describe('Icon', () => {
  it('displays icon css', () => {
    const wrapper = shallow(<Icon type="ok" />);

    expect(wrapper.html()).toEqual('<span class="pficon pficon-ok"></span>');
  });
  it('can receive additionl css classes', () => {
    const wrapper = shallow(<Icon type="ok" css="pull-left" />);

    expect(wrapper.html()).toEqual('<span class="pficon pficon-ok pull-left"></span>');
  });
});
