import {
  DELETE_MESSAGE_DIALOG_CLOSE,
  DELETE_MESSAGE_DIALOG_OPEN,
  DELETE_MESSAGE_DIALOG_REQUEST,
} from './DeleteMessageDialogConstants';

export const closeDialog = () => ({
  type: DELETE_MESSAGE_DIALOG_CLOSE,
});

export const openDialog = (name, url) => ({
  type: DELETE_MESSAGE_DIALOG_OPEN,
  payload: { name, url },
});

export const deleteItem = () => dispatch => {
  dispatch({ type: DELETE_MESSAGE_DIALOG_REQUEST });
};
