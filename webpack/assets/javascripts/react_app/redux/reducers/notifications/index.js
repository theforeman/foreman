import Immutable from 'seamless-immutable';

import {
  NOTIFICATIONS_TOGGLE_DRAWER,
  NOTIFICATIONS_SET_EXPANDED_GROUP,
  NOTIFICATIONS_MARK_AS_CLEAR,
  NOTIFICATIONS_MARK_AS_READ,
  NOTIFICATIONS_MARK_GROUP_AS_READ,
  NOTIFICATIONS_MARK_GROUP_AS_CLEARED,
  NOTIFICATIONS,
} from '../../consts';
import * as sessionStorage from '../../../components/notifications/NotificationDrawerSessionStorage';
import { actionTypeGenerator } from '../../API';

const initialState = Immutable({
  isDrawerOpen: sessionStorage.getIsOpened(),
  expandedGroup: sessionStorage.getExpandedGroup(),
  hasUnreadMessages: sessionStorage.getHasUnreadMessages() || false,
});

const hasUnreadMessages = (notifications) => {
  const result = Object.values(notifications).some((n) => !n.seen);

  // store indicator in sessionStorage.
  // TODO: consider moving this either to a reselect
  // ,store.subscribe OR to a distint redux action
  // leaving it here as it makes the most sense to me.
  sessionStorage.setHasUnreadMessages(result);
  return result;
};

const { SUCCESS, FAILURE } = actionTypeGenerator(NOTIFICATIONS);

export default (state = initialState, { type, payload, response }) => {
  switch (type) {
    case SUCCESS:
      return state.merge({
        notifications: response.notifications,
        hasUnreadMessages: hasUnreadMessages(response.notifications),
      });
    case FAILURE: {
      return state.set('error', response);
    }
    case NOTIFICATIONS_TOGGLE_DRAWER:
      return state.set('isDrawerOpen', payload.value);
    case NOTIFICATIONS_SET_EXPANDED_GROUP:
      return state.set('expandedGroup', payload.group);
    case NOTIFICATIONS_MARK_AS_READ: {
      const notifications = state.notifications.map((n) =>
        n.id === payload.id ? { ...n, seen: true } : n
      );

      return state.merge({
        notifications,
        hasUnreadMessages: hasUnreadMessages(notifications),
      });
    }
    case NOTIFICATIONS_MARK_AS_CLEAR: {
      const notifications = state.notifications.filter(
        (n) => n.id !== payload.id
      );

      return state.merge({
        notifications,
        hasUnreadMessages: hasUnreadMessages(notifications),
      });
    }
    case NOTIFICATIONS_MARK_GROUP_AS_READ: {
      const notifications = state.notifications.map((n) =>
        n.group === payload.group ? { ...n, seen: true } : n
      );

      return state.merge({
        notifications,
        hasUnreadMessages: hasUnreadMessages(notifications),
      });
    }
    case NOTIFICATIONS_MARK_GROUP_AS_CLEARED: {
      const notifications = state.notifications.filter(
        (n) => n.group !== payload.group
      );

      return state.merge({
        notifications,
        hasUnreadMessages: hasUnreadMessages(notifications),
      });
    }
    default:
      return state;
  }
};
