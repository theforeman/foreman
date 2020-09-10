import { shallow } from '@theforeman/test';
import React from 'react';

import Actions from './Actions';

describe('actions', () => {
  it('should include a cancel / submit buttons', () => {
    const wrapper = shallow(<Actions />);

    expect(wrapper).toMatchSnapshot();
  });
  it('should show disabled submit button', () => {
    const wrapper = shallow(<Actions disabled />);

    expect(wrapper).toMatchSnapshot();
  });
  it('should show a spinner when submitting', () => {
    const wrapper = shallow(<Actions submitting />);

    expect(wrapper).toMatchSnapshot();
  });
});
