import Immutable from 'seamless-immutable';
import {
  SET_MODAL_OPEN,
  SET_MODAL_CLOSED,
  ADD_MODAL,
} from './ForemanModalConstants';

const initialState = Immutable({});

// Modals state has id as key and open state as value:
// { myModal: {open: true} }
// Since keys cannot be duplicated, we avoid creating duplicate modals in this way.

export default (state = initialState, action) => {
  switch (action.type) {
    case SET_MODAL_OPEN:
      return state.setIn([action.payload.id, 'open'], true); // setIn(keypath, value)
    case SET_MODAL_CLOSED:
      return state.setIn([action.payload.id, 'open'], false);
    case ADD_MODAL:
      if (state[action.payload.id]) return state; // if it already exists, don't change its state
      return state.setIn(
        [action.payload.id, 'open'],
        action.payload.open || false
      );
    default:
      return state;
  }
};
