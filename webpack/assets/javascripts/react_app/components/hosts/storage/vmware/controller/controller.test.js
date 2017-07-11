import React from 'react';
import { shallow } from 'enzyme';
import { props } from './controller.fixtures';
import Controller from './';

let wrapper = null;

describe('StorageContainer', () => {
  beforeAll(() => {
    global.__ = str => str;
  });

  beforeEach(() => {
    wrapper = shallow(<Controller {...props} />);
  });

  it('should render controller', () => {
    expect(wrapper.render().find('.controller-container').length).toEqual(1);
  });
});
