import Immutable from 'seamless-immutable';
import { noop } from '../../common/helpers';

export const OPEN_CONFIRM_MODAL = 'OPEN_CONFIRM_MODAL';
export const CLOSE_CONFIRM_MODAL = 'CLOSE_CONFIRM_MODAL';

// actions
export const openConfirmModal = ({
  title = '',
  message = '',
  onConfirm = noop,
  onCancel = noop,
  isWarning = false,
  confirmButtonText = null,
  modalProps = {},
}) => ({
  type: OPEN_CONFIRM_MODAL,
  payload: {
    title,
    message,
    onConfirm,
    onCancel,
    modalProps,
    isWarning,
    confirmButtonText,
  },
});

export const closeConfirmModal = () => ({
  type: CLOSE_CONFIRM_MODAL,
  payload: {},
});

// reducer
const initialState = Immutable({ isOpen: false });
export const reducer = (state = initialState, { type, payload }) => {
  switch (type) {
    case OPEN_CONFIRM_MODAL:
      return state.merge({ isOpen: true, ...payload });
    case CLOSE_CONFIRM_MODAL:
      return initialState;
    default:
      return state;
  }
};

export const storeDomain = 'confirmModal';

export const reducers = { [storeDomain]: reducer };

export const selectConfirmModal = state => state[storeDomain];
