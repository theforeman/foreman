import Immutable from 'seamless-immutable';
import {
  SET_MODAL_OPEN,
  SET_MODAL_CLOSED,
  ADD_MODAL,
  SET_MODAL_START_SUBMITTING,
  SET_MODAL_STOP_SUBMITTING,
} from './ForemanModalConstants';

const initialState = Immutable({});

// Modals state has id as key and open state as value:
// { myModal: {open: true} }
// Since keys cannot be duplicated, we avoid creating duplicate modals in this way.

export default (state = initialState, action) => {
  switch (action.type) {
    case SET_MODAL_OPEN:
      return state.setIn([action.payload.id, 'isOpen'], true); // setIn(keypath, value)
    case SET_MODAL_CLOSED:
      return state.setIn([action.payload.id, 'isOpen'], false);
    case ADD_MODAL:
      if (state[action.payload.id]) return state; // if it already exists, don't change its state
      return state.setIn([action.payload.id], {
        isOpen: action.payload.isOpen || false,
        isSubmitting: action.payload.isSubmitting || false,
      });
    case SET_MODAL_START_SUBMITTING:
      return state.setIn([action.payload.id, 'isSubmitting'], true);
    case SET_MODAL_STOP_SUBMITTING:
      return state.setIn([action.payload.id, 'isSubmitting'], false);
    default:
      return state;
  }
};
