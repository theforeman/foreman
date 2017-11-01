import { TOASTS_ADD, TOASTS_DELETE, TOASTS_CLEAR } from '../../consts';
const uuidV1 = require('uuid/v1');

export const addToast = toast => {
  const key = uuidV1();

  return {
    type: TOASTS_ADD,
    payload: {
      key,
      message: { ...toast, key },
    },
  };
};

export const deleteToast = key => ({
  type: TOASTS_DELETE,
  payload: { key },
});

export const clearToasts = () => ({ type: TOASTS_CLEAR });
