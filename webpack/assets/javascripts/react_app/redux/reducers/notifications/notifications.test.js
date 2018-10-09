import * as types from '../../consts';

import {
  initialState,
  stateWithNotifications,
  panelRequest,
  NotificationRequest,
} from './notifications.fixtures';

import reducer from './index';

describe('notification reducer', () => {
  it('should return the initial state', () => {
    expect(reducer(undefined, {})).toEqual(initialState);
  });

  it('should handle NOTIFICATIONS_MARK_GROUP_AS_READ', () => {
    expect(
      reducer(stateWithNotifications, {
        type: types.NOTIFICATIONS_MARK_GROUP_AS_READ,
        payload: panelRequest,
      })
    ).toMatchSnapshot();
  });

  it('should handle NOTIFICATIONS_MARK_GROUP_AS_CLEARED', () => {
    expect(
      reducer(stateWithNotifications, {
        type: types.NOTIFICATIONS_MARK_GROUP_AS_CLEARED,
        payload: panelRequest,
      })
    ).toMatchSnapshot();
  });

  it('should handle NOTIFICATIONS_MARK_AS_CLEAR', () => {
    expect(
      reducer(stateWithNotifications, {
        type: types.NOTIFICATIONS_MARK_AS_CLEAR,
        payload: NotificationRequest,
      })
    ).toMatchSnapshot();
  });

  it('should handle NOTIFICATIONS_MARK_AS_READ', () => {
    expect(
      reducer(stateWithNotifications, {
        type: types.NOTIFICATIONS_MARK_AS_READ,
        payload: NotificationRequest,
      })
    ).toMatchSnapshot();
  });
});
