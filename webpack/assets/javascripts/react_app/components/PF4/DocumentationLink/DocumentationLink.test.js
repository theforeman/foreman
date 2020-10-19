import { shallow } from '@theforeman/test';
import React from 'react';
import Link from './index';

describe('documentation links', () => {
  it('should have an external link to documentation', () => {
    const wrapper = shallow(<Link href="http://theforeman.org" />);

    expect(wrapper).toMatchSnapshot();
  });
});
