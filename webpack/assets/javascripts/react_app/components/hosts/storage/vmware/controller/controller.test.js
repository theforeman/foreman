import { shallow } from '@theforeman/test';
import React from 'react';

import { props } from './controller.fixtures';
import Controller from './';

let wrapper = null;

describe('StorageContainer', () => {
  beforeEach(() => {
    wrapper = shallow(<Controller {...props} />);
  });

  it('should render controller', () => {
    expect(wrapper).toMatchSnapshot();
  });
});
