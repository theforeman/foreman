import Immutable from 'seamless-immutable';
import {
  AUTO_COMPLETE_REQUEST,
  AUTO_COMPLETE_SUCCESS,
  AUTO_COMPLETE_FAILURE,
  AUTO_COMPLETE_RESET,
  AUTO_COMPLETE_DISABLED_CHANGE,
} from './AutoCompleteConstants';

const initialAutocompleteState = {
  controller: null,
  error: null,
  results: [],
  searchQuery: null,
  status: null,
  trigger: null,
  url: null,
  isDisabled: false,
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
      url,
      isDisabled,
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
        url,
      });
    case AUTO_COMPLETE_SUCCESS:
      return state.setIn([id], {
        ...state[id],
        controller,
        error,
        results,
        searchQuery,
        status,
        trigger,
        url,
        isDisabled:
          isDisabled === undefined && state[id]
            ? state[id].isDisabled
            : isDisabled,
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
        isDisabled:
          isDisabled === undefined && state[id]
            ? state[id].isDisabled
            : isDisabled,
        trigger,
        controller,
      });
    case AUTO_COMPLETE_DISABLED_CHANGE:
      return state.setIn([id], {
        ...state[id],
        isDisabled,
      });
    default:
      return state;
  }
};
