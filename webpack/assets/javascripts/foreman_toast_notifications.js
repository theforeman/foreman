import * as ToastActions from './react_app/redux/actions/toasts';
import store from '../javascripts/react_app/redux';
import $ from 'jquery';

// to accommodate jnotify syntax
export function notify(message, type, sticky) {
  let toast = {
    message
  };

  if (type) {
    toast.type = type;
  }

  if (sticky) {
    toast.sticky = sticky;
  }

  showToast(toast);
}

function showToast(toast) {
  store.dispatch(ToastActions.addToast(toast));
}

// to accommodate rails flash syntax
function importFlashMessagesFromRails() {
  const notifications = $('#notifications').data().flash;

  notifications.forEach(([type, message]) => {

    // normalize rails flash names
    if (type === 'danger') {
      type = 'error';
    }

    showToast({
      type,
      message,
      sticky: (type !== 'success')
    });
  });
}

// load notifications from Rails on ContentLoad
$(document).on('ContentLoad', function () {
  importFlashMessagesFromRails();
});
