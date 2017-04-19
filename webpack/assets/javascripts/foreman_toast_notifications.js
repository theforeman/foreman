import * as ToastActions from './react_app/redux/actions/toasts';
import store from '../javascripts/react_app/redux';
import $ from 'jquery';

const isSticky = type => ['notice', 'success', 'info'].indexOf(type) === -1;

export function notify({message, type, link, sticky = isSticky(type)}) {
  store.dispatch(ToastActions.addToast({
        message,
        type,
        sticky,
        link
      }));
}

function importFlashMessagesFromRails() {
  $('#notifications').data().flash.forEach(([type, message]) => {
    notify({message, type});
  });
}

// load notifications from Rails on ContentLoad
// to accommodate rails flash syntax
$(document).on('ContentLoad', () => {
  store.dispatch(ToastActions.clearToasts());
  importFlashMessagesFromRails();
});
