import AppDispatcher from '../dispatcher';
import { ACTIONS, STATUS } from '../constants';
import NotificationActions from './NotificationActions';

export default {
 receivedNotifications(response, textStatus, jqXHR) {
   NotificationActions.setRequestStatus(STATUS.RESOLVED);
    AppDispatcher.dispatch({
      actionType: ACTIONS.RECEIVED_NOTIFICATIONS,
      notifications: response.notifications
    });
  },

  notificationsRequestError(jqXHR, textStatus, errorThrown) {
    NotificationActions.setRequestStatus(STATUS.ERROR);
    AppDispatcher.dispatch({
      actionType: ACTIONS.NOTIFICATIONS_REQUEST_ERROR, info: {
        jqXHR: jqXHR,
        textStatus: textStatus,
        errorThrown: errorThrown
      }
    });
  },

  notificationMarkedAsRead(response, textStatus, jqXHR) {
    AppDispatcher.dispatch(({
      actionType: ACTIONS.NOTIFICATIONS_MARKED_AS_READ
    }));
  }
};
