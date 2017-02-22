import AppDispatcher from '../dispatcher';
import AppEventEmitter from './AppEventEmitter';
import { ACTIONS } from '../constants';

let _notifications = {data: []};

class ToastNotificationsEventEmitter extends AppEventEmitter {
  constructor() {
    super();
  }

  getNotifications() {
    return (_notifications.data || []);
  }

}

const ToastNotificationsStore = new ToastNotificationsEventEmitter();

/* eslint-disable max-statements */
AppDispatcher.register(action => {
  switch (action.actionType) {
    case ACTIONS.RECEIVED_TOAST_NOTIFICATIONS: {
      _notifications.data.push(action.rawNotifications);

      ToastNotificationsStore.emitChange(action.actionType);
      break;
    }

    case ACTIONS.REMOVE_TOAST_NOTIFICATIONS: {
      if (action.ids.length === 0) {
        _notifications.data = [];
      } else {
        action.ids.forEach(id => {
          _notifications.data.slice(id);
        });
      }

      ToastNotificationsStore.emitChange(action.actionType);
      break;
    }

    default:
      // no op
      break;
  }
});

export default ToastNotificationsStore;
