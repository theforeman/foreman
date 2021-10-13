import store from './react_app/redux';

import { addToast, clearToasts } from './react_app/components/ToastsList';

const isStickyType = type => !['success', 'info'].includes(type);

/**
 * Notify the user with a toast-notification
 */
export const notify = ({ message, type, link, sticky = isStickyType(type) }) =>
  store.dispatch(
    addToast({
      type,
      message,
      sticky,
      link,
    })
  );

/**
 * Clear all toast notifications
 */
export const clear = () => store.dispatch(clearToasts());
