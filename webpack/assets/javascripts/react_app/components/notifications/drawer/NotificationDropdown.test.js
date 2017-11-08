// Configure Enzyme
import Adapter from 'enzyme-adapter-react-16';
import toJson from 'enzyme-to-json';
import { configure, mount } from 'enzyme';
import React from 'react';

import NotificationDropdown from './NotificationDropdown';
import { propsWithLinks } from './NotificationDropdown.fixtures';

configure({ adapter: new Adapter() });

describe('Notification dropdown', () => {
  it('Renders links provided', () => {
    const wrapper = mount(<NotificationDropdown {...propsWithLinks} />);

    expect(toJson(wrapper)).toMatchSnapshot();
  });
});
