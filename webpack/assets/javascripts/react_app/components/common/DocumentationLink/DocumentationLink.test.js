import { shallow } from '@theforeman/test';
import React from 'react';
import Link from './index';

describe('documentation links', () => {
  beforeEach(() => {
    global.__ = str => str;
  });

  it('should have an external link to documentation', () => {
    const wrapper = shallow(<Link href="http://theforeman.org" />);

    expect(wrapper).toMatchSnapshot();
  });
});
