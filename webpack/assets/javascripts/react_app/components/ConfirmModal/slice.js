import { createSlice } from '@reduxjs/toolkit';
import { noop } from '../../common/helpers';

const initialState = { isOpen: false };

const confirmModalSlice = createSlice({
  name: 'confirmModal',
  initialState,
  reducers: {
    openConfirmModal(state, action) {
      const {
        title = '',
        message = '',
        id = 'app-confirm-modal',
        onConfirm = noop,
        onCancel = noop,
        isWarning = false,
        isDireWarning = false,
        confirmButtonText = null,
        modalProps = {},
      } = action.payload;
      return {
        isOpen: true,
        title,
        message,
        id,
        onConfirm,
        onCancel,
        modalProps,
        isWarning,
        isDireWarning,
        confirmButtonText,
      };
    },
    closeConfirmModal(state) {
      return initialState;
    },
  },
});

const { name, reducer, actions } = confirmModalSlice;

export const { openConfirmModal, closeConfirmModal } = actions;

export const reducers = { [name]: reducer };

export const selectConfirmModal = state => state[name];
