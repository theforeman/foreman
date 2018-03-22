import toJson from 'enzyme-to-json';
import { shallow } from 'enzyme';
import React from 'react';

import NotificationDropdown from './NotificationDropdown';
import { propsWithLinks } from './NotificationDropdown.fixtures';

describe('Notification dropdown', () => {
  it('Renders links provided', () => {
    const wrapper = shallow(<NotificationDropdown {...propsWithLinks} />);

    expect(toJson(wrapper)).toMatchSnapshot();
  });
});
