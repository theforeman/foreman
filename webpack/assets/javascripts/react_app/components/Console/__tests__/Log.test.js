import { shallow } from '@theforeman/test';
import React from 'react';

import Log from '../Log';

describe('Console/Log', () => {
  it('should render output', () => {
    const wrapper = shallow(<Log output="I'm output \nof the console" />);

    expect(wrapper).toMatchSnapshot();
  });
});
