import ToastActions from './react_app/actions/ToastNotificationActions';
import $ from 'jquery';

export function notify(notification) {
  ToastActions.addNotification(notification);
}

function importFlashMessagesFromRails() {
  const notifications = $('#notifications').data().flash;

  notifications.forEach(([type, message]) => {

    // normalize rails flash names
    if (type === 'danger') {
      type = 'error';
    }

    notify({type, message, sticky: (type !== 'success')});
  });
}

// clear all notifications when leaving the page
$(window).bind('beforeunload', function () {
  ToastActions.closeNotifications();
});

// load notifications from Rails
$(document).on('ContentLoad', function () {
  importFlashMessagesFromRails();
});
