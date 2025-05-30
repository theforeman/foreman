import {
  NOTIFICATIONS,
  NOTIFICATIONS_MARK_AS_READ,
  NOTIFICATIONS_MARK_GROUP_AS_READ,
  NOTIFICATIONS_MARK_AS_CLEAR,
  NOTIFICATIONS_MARK_GROUP_AS_CLEARED,
  NOTIFICATIONS_URL,
} from '../../consts';
import { API, get } from '../../API';
import { reloadPage } from '../../../common/helpers';
import {
  stopInterval,
  withInterval,
} from '../../middlewares/IntervalMiddleware';
import { DEFAULT_INTERVAL } from './constants';

const interval = process.env.NOTIFICATIONS_POLLING || DEFAULT_INTERVAL;

const handleNotificationPollingError = error => {
  if (error.response?.status === 401) {
    stopNotificationsPolling();
    reloadPage();
  }
};

export const startNotificationsPolling = () =>
  withInterval(
    get({
      key: NOTIFICATIONS,
      url: NOTIFICATIONS_URL,
      handleError: handleNotificationPollingError,
    }),
    interval
  );

export const stopNotificationsPolling = () => stopInterval(NOTIFICATIONS);

export const markAsRead = id => dispatch => {
  dispatch({
    type: NOTIFICATIONS_MARK_AS_READ,
    payload: {
      id,
    },
  });
  const url = `${NOTIFICATIONS_URL}/${id}`;
  const data = { seen: true };
  API.put(url, data);
};

export const markGroupAsRead = group => dispatch => {
  dispatch({
    type: NOTIFICATIONS_MARK_GROUP_AS_READ,
    payload: {
      group,
    },
  });
  const url = `${NOTIFICATIONS_URL}/group/${group}`;
  API.put(url);
};

export const clearNotification = id => dispatch => {
  dispatch({
    type: NOTIFICATIONS_MARK_AS_CLEAR,
    payload: {
      id,
    },
  });
  const url = `${NOTIFICATIONS_URL}/${id}`;
  API.delete(url);
};

export const clearGroup = group => dispatch => {
  dispatch({
    type: NOTIFICATIONS_MARK_GROUP_AS_CLEARED,
    payload: {
      group,
    },
  });
  const url = `${NOTIFICATIONS_URL}/group/${group}`;
  API.delete(url);
};
