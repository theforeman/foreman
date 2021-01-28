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
