jest.unmock('./Alert');

import React from 'react';
import { shallow } from 'enzyme';
import Alert from './Alert';

describe('Alert', () => {
  it('displays alert css', () => {
    const wrapper = shallow(<Alert>hello</Alert>);

    expect(wrapper.html()).toEqual('<div class="alert alert-info">hello</div>');
  });
  it('can receive additionl css classes', () => {
    const wrapper = shallow(<Alert type="warning" css="pull-left">warning</Alert>);

    expect(wrapper.html()).toEqual('<div class="alert alert-warning pull-left">warning</div>');
  });
});
