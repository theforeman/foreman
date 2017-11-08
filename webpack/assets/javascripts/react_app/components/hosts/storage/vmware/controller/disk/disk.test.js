// Configure Enzyme
import Adapter from 'enzyme-adapter-react-16';
import { configure, shallow } from 'enzyme';
import React from 'react';

import { props } from './disk.fixtures';

import Disk from './';

configure({ adapter: new Adapter() });

describe('StorageContainer', () => {
  beforeEach(() => {
    global.__ = str => str;
  });

  it('renders controller correctly', () => {
    const wrapper = shallow(<Disk {...props} />);

    expect(wrapper.render().find('.text-vmware-size').length).toEqual(1);

    expect(wrapper.find('.text-vmware-size').props().value).toEqual('10 gb');
  });
});
