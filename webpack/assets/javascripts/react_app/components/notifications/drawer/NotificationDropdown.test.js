// Configure Enzyme
import { configure } from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';
configure({ adapter: new Adapter() });

import React from 'react';
import { mount } from 'enzyme';
import toJson from 'enzyme-to-json';
import NotificationDropdown from './NotificationDropdown';

import { propsWithLinks } from './NotificationDropdown.fixtures';

describe('Notification dropdown', () => {
  it('Renders links provided', () => {
    const wrapper = mount(<NotificationDropdown {...propsWithLinks} />);

    expect(toJson(wrapper)).toMatchSnapshot();
  });
});
