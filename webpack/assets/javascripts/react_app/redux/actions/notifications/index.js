import {
  NOTIFICATIONS_GET_NOTIFICATIONS,
  NOTIFICATIONS_TOGGLE_DRAWER,
  NOTIFICATIONS_SET_EXPANDED_GROUP,
  NOTIFICATIONS_MARK_AS_READ,
  NOTIFICATIONS_MARK_GROUP_AS_READ,
  NOTIFICATIONS_POLLING_STARTED
} from '../../consts';
import {
  notificationsDrawer as sessionStorage
} from '../../../common/sessionStorage';
import API from '../../../API';
import { isNil } from 'lodash';
const defaultNotificationsPollingInterval = 10000;
const notificationsInterval = isNil(process.env.NOTIFICATIONS_POLLING) ?
  defaultNotificationsPollingInterval :
  process.env.NOTIFICATIONS_POLLING;

const getNotifications = url => dispatch => {
  const isDocumentVisible =
    document.visibilityState === 'visible' ||
    document.visibilityState === 'prerender';

  if (isDocumentVisible) {
    API.get(url)
    .done(onGetNotificationsSuccess)
    .fail(onGetNotificationsFailed)
    .always(triggerPolling);
  } else {
    // document is not visible, keep polling without api call
    triggerPolling();
  }

  function onGetNotificationsSuccess(response) {
    dispatch({
      type: NOTIFICATIONS_GET_NOTIFICATIONS,
      payload: {
        notifications: response.notifications
      }
    });
  }

  function onGetNotificationsFailed(error) {
    if (error.status === 401) {
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
    type: NOTIFICATIONS_POLLING_STARTED
  });
  dispatch(getNotifications(url));
};

export const onMarkAsRead = (group, id) => dispatch => {
  dispatch({
    type: NOTIFICATIONS_MARK_AS_READ,
    payload: {
      group,
      id
    }
  });
  API.markNotificationAsRead(id);
};

export const onMarkGroupAsRead = group => dispatch => {
  dispatch({
    type: NOTIFICATIONS_MARK_GROUP_AS_READ,
    payload: {
      group
    }
  });
  API.markGroupNotificationAsRead(group);
};

export const expandGroup = group => (dispatch, getState) => {
  const currentExpanded = getState().notifications.expandedGroup;

  const getNewExpandedGroup = () => (currentExpanded === group ? '' : group);

  sessionStorage.setExpandedGroup(getNewExpandedGroup());
  dispatch({
    type: NOTIFICATIONS_SET_EXPANDED_GROUP,
    payload: {
      group: getNewExpandedGroup()
    }
  });
};

export const toggleDrawer = () => (dispatch, getState) => {
  const isDrawerOpened = getState().notifications.isDrawerOpen;

  sessionStorage.setIsOpened(!isDrawerOpened);
  dispatch({
    type: NOTIFICATIONS_TOGGLE_DRAWER,
    payload: {
      value: !isDrawerOpened
    }
  });
};

export const onClickedLink = link => (dispatch, getState) => {
  toggleDrawer()(dispatch, getState);
  window.open(link.href, link.external ? '_blank' : '_self');
};
