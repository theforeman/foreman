import { some } from 'lodash';
import Immutable from 'seamless-immutable';

import {
  NOTIFICATIONS_GET_NOTIFICATIONS,
  NOTIFICATIONS_TOGGLE_DRAWER,
  NOTIFICATIONS_SET_EXPANDED_GROUP,
  NOTIFICATIONS_MARK_AS_READ,
  NOTIFICATIONS_MARK_GROUP_AS_READ,
  NOTIFICATIONS_POLLING_STARTED,
} from '../../consts';
import { notificationsDrawer } from '../../../common/sessionStorage';

const initialState = Immutable({
  isDrawerOpen: notificationsDrawer.getIsOpened(),
  expandedGroup: notificationsDrawer.getExpandedGroup(),
  isPolling: false,
  hasUnreadMessages: notificationsDrawer.getHasUnreadMessages() || false,
});

const hasUnreadMessages = (notifications) => {
  const result = some(notifications, n => !n.seen);

  // store indicator in sessionStorage.
  // TODO: consider moving this either to a reselect
  // ,store.subscribe OR to a distint redux action
  // leaving it here as it makes the most sense to me.
  notificationsDrawer.setHasUnreadMessages(result);
  return result;
};

export default (state = initialState, action) => {
  const { payload } = action;

  switch (action.type) {
    case NOTIFICATIONS_POLLING_STARTED:
      return state.set('isPolling', true);
    case NOTIFICATIONS_GET_NOTIFICATIONS:
      return state
        .set('notifications', payload.notifications)
        .set('hasUnreadMessages', hasUnreadMessages(payload.notifications));
    case NOTIFICATIONS_TOGGLE_DRAWER:
      return state.set('isDrawerOpen', payload.value);
    case NOTIFICATIONS_SET_EXPANDED_GROUP:
      return state.set('expandedGroup', payload.group);
    case NOTIFICATIONS_MARK_AS_READ: {
      const notifications = state.notifications.map(n => (
        n.id === payload.id ? Object.assign({}, n, { seen: true }) : n));

      return state
        .set('notifications', notifications)
        .set('hasUnreadMessages', hasUnreadMessages(notifications));
    }
    case NOTIFICATIONS_MARK_GROUP_AS_READ: {
      const notifications = state.notifications.map(n => (
        n.group === payload.group ? Object.assign({}, n, { seen: true }) : n));

      return state
        .set('notifications', notifications)
        .set('hasUnreadMessages', hasUnreadMessages(notifications));
    }
    default:
      return state;
  }
};
