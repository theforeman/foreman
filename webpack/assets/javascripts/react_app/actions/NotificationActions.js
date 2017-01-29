import API from '../API';
import AppDispatcher from '../dispatcher';
import NotificationsStore from '../stores/NotificationsStore';
import { ACTIONS, STATUS } from '../constants';

const TIMER = 10000;

export default {
  getNotifications(url) {
    if ((document.visibilityState === 'visible'  || document.visibilityState === 'prerender') &&
      NotificationsStore.getRequestStatus() === STATUS.RESOLVED) {
      API.getNotifications(url);
    }

    setTimeout(() => {
      this.getNotifications(url);
    }, TIMER);
  },
  setRequestStatus(status) {
    AppDispatcher.dispatch({
      actionType: ACTIONS.NOTIFICATIONS_SET_REQUEST_STATUS,
      status: status
    });
  },
  toggleNotificationDrawer() {
    AppDispatcher.dispatch({
      actionType: ACTIONS.NOTIFICATIONS_DRAWER_TOGGLE
    });
  },
  expandDrawerTab(group) {
    AppDispatcher.dispatch({
      actionType: ACTIONS.NOTIFICATIONS_EXPAND_DRAWER_TAB,
      expand: group
    });
  },
  markAsRead(url) {
    API.markNotificationAsRead(url);
  }
};
