import API from '../API';
import AppDispatcher from '../dispatcher';
import {ACTIONS} from '../constants';

const TIMER = 10000;

export default {
  getNotifications(url) {
    if (document.visibilityState === 'visible') {
      API.getNotifications(url);
    }
    setTimeout(() => {
      this.getNotifications(url);
    }, TIMER);
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
