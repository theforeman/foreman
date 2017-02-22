import AppDispatcher from '../dispatcher';
import { ACTIONS } from '../constants';

export default {
  addNotification(rawNotifications) {
    AppDispatcher.dispatch({
      actionType: ACTIONS.RECEIVED_TOAST_NOTIFICATIONS,
      rawNotifications
    });
  },
  closeNotifications(ids = []) {
    AppDispatcher.dispatch({
      actionType: ACTIONS.REMOVE_TOAST_NOTIFICATIONS,
      ids
    });
  }
};
