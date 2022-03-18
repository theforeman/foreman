import Immutable from 'seamless-immutable';
import {
  AUTO_COMPLETE_INIT,
  AUTO_COMPLETE_REQUEST,
  AUTO_COMPLETE_SUCCESS,
  AUTO_COMPLETE_FAILURE,
  AUTO_COMPLETE_RESET,
  AUTO_COMPLETE_DISABLED_CHANGE,
  AUTO_COMPLETE_CONTROLLER_CHANGE,
  TRIGGERS,
  AUTO_COMPLETE_SET_QUERY,
} from './AutoCompleteConstants';

const initialAutocompleteState = {
  controller: null,
  error: null,
  isErrorVisible: false,
  results: [],
  searchQuery: '',
  status: null,
  trigger: null,
  url: undefined,
  disabled: false,
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
      isErrorVisible,
      id,
      disabled,
      url,
    } = {},
  } = action;
  switch (type) {
    case AUTO_COMPLETE_INIT:
      return state.setIn([id], {
        ...state[id],
        controller,
        error,
        isErrorVisible,
        results,
        searchQuery,
        status,
        trigger,
        disabled,
        url,
      });
    case AUTO_COMPLETE_REQUEST:
      return state.setIn([id], {
        ...state[id],
        controller,
        error,
        searchQuery,
        status,
        trigger,
        url,
      });
    case AUTO_COMPLETE_SUCCESS:
      return state.setIn([id], {
        ...state[id],
        results,
        status,
      });
    case AUTO_COMPLETE_FAILURE:
      return state.setIn([id], {
        ...state[id],
        error,
        isErrorVisible,
        results,
        status,
      });
    case AUTO_COMPLETE_RESET:
      return state.setIn([id], {
        ...initialAutocompleteState,
        trigger: TRIGGERS.RESET,
      });
    case AUTO_COMPLETE_DISABLED_CHANGE:
      return state.setIn([id], {
        ...state[id],
        disabled,
      });
    case AUTO_COMPLETE_CONTROLLER_CHANGE:
      return state.setIn([id], {
        ...state[id],
        controller,
        url,
        trigger,
      });
    case AUTO_COMPLETE_SET_QUERY:
      return state.setIn([id], {
        ...state[id],
        searchQuery,
      });
    default:
      return state;
  }
};
