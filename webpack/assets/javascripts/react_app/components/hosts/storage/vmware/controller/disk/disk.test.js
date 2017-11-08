// Configure Enzyme
import { configure } from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';
configure({ adapter: new Adapter() });

import React from 'react';
import { shallow } from 'enzyme';
import { props } from './disk.fixtures';
import Disk from './';

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
