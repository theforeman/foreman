import { shallow } from 'enzyme';
import React from 'react';

import { props } from './disk.fixtures';
import Disk from './';

describe('StorageContainer', () => {
  it('renders controller correctly', () => {
    const wrapper = shallow(<Disk {...props} />);

    expect(wrapper.render().find('.text-vmware-size').length).toEqual(1);

    expect(wrapper.find('.text-vmware-size').props().value).toEqual(10);
  });
});
