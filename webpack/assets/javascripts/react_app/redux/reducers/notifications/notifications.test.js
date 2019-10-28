import * as types from '../../consts';

import {
  initialState,
  stateWithNotifications,
  panelRequest,
  NotificationRequest,
  notifications,
} from './notifications.fixtures';

import reducer from './index';
import { actionTypeGenerator } from '../../API';
import { redirectToLogin } from './helpers';

jest.mock('./helpers.js', () => ({
  redirectToLogin: jest.fn(),
}));

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

  it('Should handle SUCCESS', () => {
    const { SUCCESS } = actionTypeGenerator(types.NOTIFICATIONS);

    const action = {
      type: SUCCESS,
      payload: {
        notifications,
      },
    };
    expect(reducer(stateWithNotifications, action)).toMatchSnapshot();
  });

  it('Should handle FAILURE', () => {
    const { FAILURE } = actionTypeGenerator(types.NOTIFICATIONS);
    const action = {
      type: FAILURE,
      payload: {
        error: {
          response: {
            status: 401,
          },
        },
      },
    };
    expect(reducer(stateWithNotifications, action)).toMatchSnapshot();
    expect(redirectToLogin).toBeCalled();
  });
});
