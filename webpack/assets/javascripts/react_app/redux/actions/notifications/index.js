import {
  NOTIFICATIONS_GET_NOTIFICATIONS,
  NOTIFICATIONS_TOGGLE_DRAWER,
  NOTIFICATIONS_SET_EXPANDED_GROUP,
  NOTIFICATIONS_MARK_AS_READ,
  NOTIFICATIONS_MARK_GROUP_AS_READ,
  NOTIFICATIONS_MARK_AS_CLEAR,
  NOTIFICATIONS_MARK_GROUP_AS_CLEARED,
  NOTIFICATIONS_POLLING_STARTED,
  NOTIFICATIONS_LINK_CLICKED,
} from '../../consts';
import { doesDocumentHasFocus } from '../../../common/document';
import { notificationsDrawer as sessionStorage } from '../../../common/sessionStorage';
import API from '../../../API';

const defaultNotificationsPollingInterval = 10000;
const notificationsInterval =
  process.env.NOTIFICATIONS_POLLING || defaultNotificationsPollingInterval;

const getNotifications = url => dispatch => {
  if (doesDocumentHasFocus()) {
    API.get(url)
      .then(onGetNotificationsSuccess)
      .catch(onGetNotificationsFailed)
      .then(triggerPolling);
  } else {
    // document is not visible, keep polling without api call
    triggerPolling();
  }

  function onGetNotificationsSuccess({ data }) {
    dispatch({
      type: NOTIFICATIONS_GET_NOTIFICATIONS,
      payload: {
        notifications: data.notifications,
      },
    });
  }

  function onGetNotificationsFailed(error) {
    if (error.response.status === 401) {
      window.location.replace('/users/login');
    }
  }

  function triggerPolling() {
    if (notificationsInterval) {
      setTimeout(() => dispatch(getNotifications(url)), notificationsInterval);
    }
  }
};

export const startNotificationsPolling = url => (dispatch, getState) => {
  if (getState().notifications.isPolling) {
    return;
  }
  dispatch({
    type: NOTIFICATIONS_POLLING_STARTED,
  });
  dispatch(getNotifications(url));
};

export const markAsRead = (group, id) => dispatch => {
  dispatch({
    type: NOTIFICATIONS_MARK_AS_READ,
    payload: {
      group,
      id,
    },
  });
  const url = `/notification_recipients/${id}`;
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
  const url = `/notification_recipients/group/${group}`;
  API.put(url);
};

export const clearNotification = (group, id) => dispatch => {
  dispatch({
    type: NOTIFICATIONS_MARK_AS_CLEAR,
    payload: {
      group,
      id,
    },
  });
  const url = `/notification_recipients/${id}`;
  API.delete(url);
};

export const clearGroup = group => dispatch => {
  dispatch({
    type: NOTIFICATIONS_MARK_GROUP_AS_CLEARED,
    payload: {
      group,
    },
  });
  const url = `/notification_recipients/group/${group}`;
  API.delete(url);
};

export const expandGroup = group => (dispatch, getState) => {
  const currentExpanded = getState().notifications.expandedGroup;

  const getNewExpandedGroup = () => (currentExpanded === group ? '' : group);

  sessionStorage.setExpandedGroup(getNewExpandedGroup());
  dispatch({
    type: NOTIFICATIONS_SET_EXPANDED_GROUP,
    payload: {
      group: getNewExpandedGroup(),
    },
  });
};

export const toggleDrawer = () => (dispatch, getState) => {
  const isDrawerOpened = getState().notifications.isDrawerOpen;

  sessionStorage.setIsOpened(!isDrawerOpened);
  dispatch({
    type: NOTIFICATIONS_TOGGLE_DRAWER,
    payload: {
      value: !isDrawerOpened,
    },
  });
};

export const clickedLink = (
  { href, external = false },
  toggleDrawerAction = toggleDrawer
) => dispatch => {
  dispatch(toggleDrawerAction());

  const openedWindow = window.open(href, external ? '_blank' : '_self');

  if (external) {
    openedWindow.opener = null;
  }

  dispatch({
    type: NOTIFICATIONS_LINK_CLICKED,
    payload: { href, external },
  });

  return openedWindow;
};
