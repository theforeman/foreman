import reducer from './index';
import * as types from '../../consts';
import {
  initialState,
  stateWithNotifications,
  request,
  response,
} from './notifications.fixtures';

describe('notification reducer', () => {
  it('should return the initial state', () => {
    expect(reducer(undefined, {})).toEqual(initialState);
  });

  it('should handle NOTIFICATIONS_MARK_GROUP_AS_READ', () => {
    expect(
      reducer(stateWithNotifications, {
        type: types.NOTIFICATIONS_MARK_GROUP_AS_READ,
        payload: request,
      })
    ).toEqual(response);
  });
});
