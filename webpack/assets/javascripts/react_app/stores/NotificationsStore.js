import AppDispatcher from '../dispatcher';
import { ACTIONS, STATUS } from '../constants';
import AppEventEmitter from './AppEventEmitter';
import moment from 'moment';

let _notifications = {};
let _requestStatus = STATUS.RESOLVED;

class NotificationsEventEmitter extends AppEventEmitter {
  constructor() {
    super();
  }

  getNotifications() {
    return (_notifications.data || []);
  }

  getIsDrawerOpen() {
    const value = window.sessionStorage.getItem('isDrawerOpen') || 'false';

    return JSON.parse(value);
  }

  getExpandedGroup() {
    const value = window.sessionStorage.getItem('expandedGroup') || null;

    return JSON.parse(value);
  }

  getRequestStatus() {
    return _requestStatus;
  }

  prepareNotifications(notifications) {
    let preparedData = {};
    let sortedData = {};
    let keys;

    notifications.forEach((notification) => {
      const group = notification.group;
      const value = notification;

      if (!preparedData[group]) {
        preparedData[group] = [value];
      } else {
        preparedData[group].push(value);
      }
    });

    keys = Object.keys(preparedData);

    keys.forEach((key) => {
      sortedData[key] = preparedData[key].sort(compare);
    });
    return sortedData;
  }
}

const NotificationsStore = new NotificationsEventEmitter();

/* eslint-disable max-statements */
AppDispatcher.register(action => {
  switch (action.actionType) {
    case ACTIONS.RECEIVED_NOTIFICATIONS: {
      _notifications.data = NotificationsStore.prepareNotifications(action.notifications);

      NotificationsStore.emitChange(action.actionType);
      break;
    }
    case ACTIONS.NOTIFICATIONS_REQUEST_ERROR: {
      NotificationsStore.emitError(action.info);
      break;
    }

    case ACTIONS.NOTIFICATIONS_DRAWER_TOGGLE: {
      const value = NotificationsStore.getIsDrawerOpen();

      window.sessionStorage.setItem('isDrawerOpen', JSON.stringify(!value));
      NotificationsStore.emitChange(action.actionType);
      break;
    }

    case ACTIONS.NOTIFICATIONS_EXPAND_DRAWER_TAB: {
      let expandedTab = NotificationsStore.getExpandedGroup();

      if (expandedTab === action.expand) {
        window.sessionStorage.setItem('expandedGroup', JSON.stringify(null));
      } else {
        window.sessionStorage.setItem('expandedGroup', JSON.stringify(action.expand));
      }

      NotificationsStore.emitChange(action.actionType);
      break;
    }

    case ACTIONS.NOTIFICATIONS_SET_REQUEST_STATUS: {
      _requestStatus = action.status;
      break;
    }

    default:
      // no op
      break;
  }
});

/* eslint-enable max-statements */

export default NotificationsStore;

// sort notifications by time descending
function compare(a, b) {
  const diff = moment(a.created_at) - moment(b.created_at);
  let returnValue;

  if (diff < 0) {
    returnValue = 1;
  } else if (diff > 0) {
    returnValue = -1;
  } else {
    returnValue = 0;
  }
  return returnValue;
}
