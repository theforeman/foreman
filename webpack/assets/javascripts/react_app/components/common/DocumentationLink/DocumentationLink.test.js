import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';

import React from 'react';
import Link from './index';

describe('documentation links', () => {
  beforeEach(() => {
    global.__ = str => str;
  });

  it('should have an external link to documentation', () => {
    const wrapper = shallow(<Link href="http://theforeman.org" />);

    expect(toJson(wrapper)).toMatchSnapshot();
  });
});
