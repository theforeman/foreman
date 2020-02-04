import Immutable from 'seamless-immutable';
import {
  INIT,
  UPDATE_OPTIONS,
  UPDATE_SELECTED,
} from './TypeAheadSelectConstants';

const initialState = Immutable({});

export default (
  state = initialState,
  { type, payload: { id, options, selected } = {} }
) => {
  switch (type) {
    case INIT:
      return state.setIn([id], {
        ...state[id],
        options,
        selected,
      });
    case UPDATE_OPTIONS:
      return state.setIn([id], {
        ...state[id],
        options,
      });
    case UPDATE_SELECTED:
      return state.setIn([id], {
        ...state[id],
        selected,
      });
    default:
      return state;
  }
};
