import { shallow } from 'enzyme';
import React from 'react';

import Icon from './';

jest.unmock('./');

describe('Icon', () => {
  it('displays ok icon css', () => {
    const wrapper = shallow(<Icon type="ok" />);

    expect(wrapper.html()).toEqual('<span class="pficon pficon-ok"></span>');
  });
  it('displays info icon css', () => {
    const wrapper = shallow(<Icon type="info" />);

    expect(wrapper.html()).toEqual('<span class="pficon pficon-info"></span>');
  });
  it('displays warning icon css', () => {
    const wrapper = shallow(<Icon type="warning" />);

    expect(wrapper.html()).toEqual('<span class="pficon pficon-warning-triangle-o"></span>');
  });
  it('displays error icon css', () => {
    const wrapper = shallow(<Icon type="error" />);

    expect(wrapper.html()).toEqual('<span class="pficon pficon-error-circle-o"></span>');
  });
  it('displays close icon css', () => {
    const wrapper = shallow(<Icon type="close" />);

    expect(wrapper.html()).toEqual('<span class="pficon pficon-close"></span>');
  });
});
