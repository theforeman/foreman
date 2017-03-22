import {
  NOTIFICATIONS_GET_NOTIFICATIONS,
  NOTIFICATIONS_TOGGLE_DRAWER,
  NOTIFICATIONS_SET_EXPANDED_GROUP,
  NOTIFICATIONS_MARK_AS_READ
} from '../../consts';
import Immutable from 'seamless-immutable';
import { notificationsDrawer } from '../../../common/sessionStorage';

const initialState = Immutable({
  isDrawerOpen: notificationsDrawer.getIsOpened(),
  expandedGroup: notificationsDrawer.getExpandedGroup()
});

export default (state = initialState, action) => {
  const { payload } = action;

  switch (action.type) {
    case NOTIFICATIONS_GET_NOTIFICATIONS:
      return state.set(
        'notifications', payload.notifications
      );
    case NOTIFICATIONS_TOGGLE_DRAWER:
      return state.set('isDrawerOpen', payload.value);
    case NOTIFICATIONS_SET_EXPANDED_GROUP:
      return state.set('expandedGroup', payload.group);
    case NOTIFICATIONS_MARK_AS_READ:
      return state.set(
        'notifications',
        state.notifications.map(
          n => n.id === payload.id ?
            Object.assign({}, n, {seen: true}) :
            n
        )
      );
    default:
      return state;
  }
};
