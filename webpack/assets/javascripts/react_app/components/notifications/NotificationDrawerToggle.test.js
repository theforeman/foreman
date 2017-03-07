jest.unmock('./NotificationDrawerToggle');
jest.unmock('../../stores/NotificationsStore');
import testHelpers from '../../common/testHelpers';

import React from 'react';
import { shallow } from 'enzyme';
import NotificationDrawerToggle from './NotificationDrawerToggle';
import NotificationsStore from '../../stores/NotificationsStore';
import NotificationActions from '../../actions/NotificationActions';

function setup() {
  return shallow(<NotificationDrawerToggle />);
}

describe('NotificationDrawerToggle', () => {
  beforeEach(() => {
    global.__ = (text) => text;
    global.sessionStorage = testHelpers.mockStorage();
  });

  it('should show bell icon', () => {
    const wrapper = setup();
    const emptyBellIcon = wrapper.find('.fa-bell-o');
    const fullBellIcon = wrapper.find('.fa-bell');

    expect(emptyBellIcon.length || fullBellIcon.length).toBe(1);
  });

  it('stores show/hide status in store', () => {
    NotificationActions.getNotifications = jest.fn();

    const wrapper = setup();

    expect(NotificationsStore.getIsDrawerOpen()).toBe(false);

    wrapper.simulate('click');

    expect(NotificationsStore.getIsDrawerOpen()).toBe(true);

    wrapper.simulate('click');

    expect(NotificationsStore.getIsDrawerOpen()).toBe(false);
  });
});
