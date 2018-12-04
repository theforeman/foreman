import Immutable from 'seamless-immutable';
import {
  DELETE_MESSAGE_DIALOG_CLOSE,
  DELETE_MESSAGE_DIALOG_OPEN,
  DELETE_MESSAGE_DIALOG_REQUEST,
} from './DeleteMessageDialogConstants';

const initialState = Immutable({
  show: false,
  processing: false,
  name: '',
  url: '',
});

export default (state = initialState, action) => {
  switch (action.type) {
    case DELETE_MESSAGE_DIALOG_CLOSE:
      return state.merge({
        show: false,
        processing: false,
      });
    case DELETE_MESSAGE_DIALOG_OPEN:
      return state.merge({
        ...action.payload,
        show: true,
      });
    case DELETE_MESSAGE_DIALOG_REQUEST:
      return state.set('processing', true);
    default:
      return state;
  }
};
