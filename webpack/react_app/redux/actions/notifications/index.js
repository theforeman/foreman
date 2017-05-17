import {
  NOTIFICATIONS_GET_NOTIFICATIONS,
  NOTIFICATIONS_TOGGLE_DRAWER,
  NOTIFICATIONS_SET_EXPANDED_GROUP,
  NOTIFICATIONS_MARK_AS_READ,
  NOTIFICATIONS_MARK_GROUP_AS_READ
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

export const getNotifications = url => dispatch => {
  new Promise((resolve, reject) => {
    if (
      document.visibilityState === 'visible' ||
      document.visibilityState === 'prerender'
    ) {
      API.get(url).then(
        response => {
          dispatch({
            type: NOTIFICATIONS_GET_NOTIFICATIONS,
            payload: {
              notifications: response.notifications
            }
          });
          resolve();
        },
        () => reject()
      );
    } else {
      resolve();
    }
    return null;
  }).then(
    () => {
      if (notificationsInterval) {
        setTimeout(
          () => dispatch(getNotifications(url)),
          notificationsInterval
        );
      }
    },
    // error handling
    () => {}
  );
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

export const onMarkGroupAsRead = (group) => dispatch => {
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

  const getNewExpandedGroup = () => currentExpanded === group ? '' : group;

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
