import Immutable from 'seamless-immutable';
import {
  AUTO_COMPLETE_REQUEST,
  AUTO_COMPLETE_SUCCESS,
  AUTO_COMPLETE_FAILURE,
  AUTO_COMPLETE_RESET,
} from './AutoCompleteConstants';

const initialState = Immutable({
  controller: null,
  error: null,
  results: [],
  searchQuery: '',
  status: null,
  trigger: null,
});

export default (state = initialState, action) => {
  const {
    type,
    payload: {
      controller, error, results, searchQuery, status, trigger,
    } = {},
  } = action;
  switch (type) {
    case AUTO_COMPLETE_REQUEST:
      return state.merge({
        controller,
        error: null,
        searchQuery,
        status,
        trigger,
      });
    case AUTO_COMPLETE_SUCCESS:
      return state.merge({
        controller,
        error: null,
        results,
        searchQuery,
        status,
        trigger,
      });
    case AUTO_COMPLETE_FAILURE:
      return state.merge({
        error,
        results,
        status,
      });
    case AUTO_COMPLETE_RESET:
      return state.merge({ ...initialState });
    default:
      return state;
  }
};
