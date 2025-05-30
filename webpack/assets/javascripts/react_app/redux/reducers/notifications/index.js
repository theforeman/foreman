import Immutable from 'seamless-immutable';

import {
  NOTIFICATIONS_MARK_AS_CLEAR,
  NOTIFICATIONS_MARK_AS_READ,
  NOTIFICATIONS_MARK_GROUP_AS_READ,
  NOTIFICATIONS_MARK_GROUP_AS_CLEARED,
  NOTIFICATIONS,
} from '../../consts';
import * as sessionStorage from '../../../components/notifications/NotificationDrawerSessionStorage';
import { actionTypeGenerator } from '../../API';

const initialState = Immutable({
  hasUnreadMessages: sessionStorage.getHasUnreadMessages() || false,
});

const hasUnreadMessages = notifications => {
  const result = Object.values(notifications).some(n => !n.seen);
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
    case NOTIFICATIONS_MARK_AS_READ: {
      const notifications = state.notifications.map(n =>
        n.id === payload.id ? { ...n, seen: true } : n
      );

      return state.merge({
        notifications,
        hasUnreadMessages: hasUnreadMessages(notifications),
      });
    }
    case NOTIFICATIONS_MARK_AS_CLEAR: {
      const notifications = state.notifications.filter(
        n => n.id !== payload.id
      );

      return state.merge({
        notifications,
        hasUnreadMessages: hasUnreadMessages(notifications),
      });
    }
    case NOTIFICATIONS_MARK_GROUP_AS_READ: {
      const notifications = state.notifications.map(n =>
        n.group === payload.group ? { ...n, seen: true } : n
      );

      return state.merge({
        notifications,
        hasUnreadMessages: hasUnreadMessages(notifications),
      });
    }
    case NOTIFICATIONS_MARK_GROUP_AS_CLEARED: {
      const notifications = state.notifications.filter(
        n => n.group !== payload.group
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
