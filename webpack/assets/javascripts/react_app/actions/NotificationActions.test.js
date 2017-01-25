jest.unmock('./NotificationActions');
jest.unmock('../constants');
jest.unmock('../stores/NotificationsStore');

import NotificationActions from './NotificationActions';
import NotificationsStore from '../stores/NotificationsStore';
import { STATUS } from '../constants';
import API from '../API';

describe('NotificationsActions', () => {
  function setup(status) {
    jest.useFakeTimers();
    API.getNotifications = jest.fn();
    NotificationsStore.getRequestStatus = jest.fn().mockReturnValue(status);
  }

  it('calls API.getNotifications only when request status is resolved', () => {
    setup(STATUS.RESOLVED);

    NotificationActions.getNotifications('x');

    expect(API.getNotifications).toHaveBeenCalled();
  });
  it('does not call API.getNotifications prev request returned error', () => {
    setup(STATUS.ERROR);

    NotificationActions.getNotifications('x');

    expect(API.getNotifications).not.toHaveBeenCalled();
  });
  it('does not call API.getNotifications request is pending', () => {
    setup(STATUS.PENDING);

    NotificationActions.getNotifications('x');

    expect(API.getNotifications).not.toHaveBeenCalled();
  });
});
