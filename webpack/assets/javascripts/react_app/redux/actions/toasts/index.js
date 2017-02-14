import {
  TOASTS_ADD,
  TOASTS_HIDE,
  TOASTS_DELETE
  // TOASTS_STORE_IN_LOCALSTORAGE,
  // TOASTS_GET_FROM_LOCALSTORAGE
} from '../../consts';

// provide mechanism to persist toasts to localStorage
export const addToast = (toast) => {
  const payload = Object.assign({}, toast, {visible: true});

  return { type: TOASTS_ADD, payload: payload };
};

export const hideToast = (id) => {
  const payload = { id };

  return { type: TOASTS_HIDE, payload: payload };
};

export const deleteToast = (id) => {
  const payload = { id };

  return { type: TOASTS_DELETE, payload: payload };
};
