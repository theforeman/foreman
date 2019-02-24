import Immutable from 'seamless-immutable';
import {
  AUTO_COMPLETE_REQUEST,
  AUTO_COMPLETE_SUCCESS,
  AUTO_COMPLETE_FAILURE,
  AUTO_COMPLETE_RESET,
} from './AutoCompleteConstants';

const initialAutocompleteState = {
  controller: null,
  error: null,
  results: [],
  searchQuery: '',
  status: null,
  trigger: null,
};

export default (state = Immutable({}), action) => {
  const {
    type,
    payload: {
      controller,
      error,
      results,
      searchQuery,
      status,
      trigger,
      id,
    } = {},
  } = action;
  switch (type) {
    case AUTO_COMPLETE_REQUEST:
      return state.setIn([id], {
        ...state[id],
        controller,
        error: null,
        searchQuery,
        status,
        trigger,
      });
    case AUTO_COMPLETE_SUCCESS:
      return state.setIn([id], {
        ...state[id],
        controller,
        error: null,
        results,
        searchQuery,
        status,
        trigger,
      });
    case AUTO_COMPLETE_FAILURE:
      return state.setIn([id], {
        ...state[id],
        error,
        results,
        status,
      });
    case AUTO_COMPLETE_RESET:
      return state.setIn([id], {
        ...initialAutocompleteState,
        controller,
      });
    default:
      return state;
  }
};
