import $ from 'jquery';

import store from './react_app/redux';

import * as ToastActions from './react_app/redux/actions/toasts';

const isStickyType = type => !['success', 'info'].includes(type);

/**
 * Notify the user with a toast-notification
 */
export const notify = ({ message, type, link, sticky = isStickyType(type) }) =>
  store.dispatch(
    ToastActions.addToast({
      type,
      message,
      sticky,
      link,
    })
  );

/**
 * Clear all toast notifications
 */
export const clear = () => store.dispatch(ToastActions.clearToasts());

const railsNotificationToToastNotification = ({ link, type, message }) => {
  const toast = { type, message };

  if (link) {
    toast.link = { href: link.href, children: link.text };
  }

  return toast;
};

const importToastNotificationsFromRails = () => {
  const toastNotificationsContainer = $('#toast-notifications-container');
  if (toastNotificationsContainer.length === 0) return;

  const notifications = toastNotificationsContainer.data('notifications');
  if (!notifications) return;

  // notify each rails notification
  notifications
    .map(railsNotification =>
      railsNotificationToToastNotification(railsNotification)
    )
    .forEach(toastNotification => notify(toastNotification));

  // remove both jquery cache and dom entry to avoid ajax ContentLoad events
  // reloading our toast notifications
  toastNotificationsContainer.attr('data-notifications', '').removeData();
};

// load toast notifications from Rails on ContentLoad
// to accommodate rails flash syntax
$(document).on('ContentLoad', () => {
  clear();
  importToastNotificationsFromRails();
});
