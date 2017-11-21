import toJson from 'enzyme-to-json';
import { mount } from 'enzyme';
import React from 'react';

import NotificationDropdown from './NotificationDropdown';
import { propsWithLinks } from './NotificationDropdown.fixtures';

describe('Notification dropdown', () => {
  it('Renders links provided', () => {
    const wrapper = mount(<NotificationDropdown {...propsWithLinks} />);

    expect(toJson(wrapper)).toMatchSnapshot();
  });
});
