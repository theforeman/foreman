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
