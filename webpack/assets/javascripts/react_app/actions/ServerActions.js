import AppDispatcher from '../dispatcher';
import {ACTIONS} from '../constants';

export default {
  receivedStatistics(rawStatistics, textStatus, jqXHR) {
    AppDispatcher.dispatch({
      actionType: ACTIONS.RECEIVED_STATISTICS,
      rawStatistics
    });
  },

  statisticsRequestError(jqXHR, textStatus, errorThrown) {
    AppDispatcher.dispatch({
      actionType: ACTIONS.STATISTICS_REQUEST_ERROR, info: {
        jqXHR: jqXHR,
        textStatus: textStatus,
        errorThrown: errorThrown
      }
    });
  },
    receivedHostsPowerState(response, textStatus, jqXHR) {
    AppDispatcher.dispatch({
      actionType: ACTIONS.RECEIVED_HOSTS_POWER_STATE,
      response
    });
  },
  hostsRequestError(jqXHR, textStatus, errorThrown) {
    AppDispatcher.dispatch({
      actionType: ACTIONS.HOSTS_REQUEST_ERROR, info: {
        jqXHR: jqXHR,
        textStatus: textStatus,
        id: parseInt(jqXHR.originalRequestOptions.url.split('/')[2], 10),
        errorThrown: errorThrown
      }
    });
  },
 receivedNotifications(response, textStatus, jqXHR) {
    AppDispatcher.dispatch({
      actionType: ACTIONS.RECEIVED_NOTIFICATIONS,
      notifications: response.notifications
    });
  },

  notificationsRequestError(jqXHR, textStatus, errorThrown) {
    AppDispatcher.dispatch({
      actionType: ACTIONS.NOTIFICATIONSS_REQUEST_ERROR, info: {
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
