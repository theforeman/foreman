import Immutable from 'seamless-immutable';
import {
  BOOKMARKS_REQUEST,
  BOOKMARKS_SUCCESS,
  BOOKMARKS_FAILURE,
  BOOKMARKS_FORM_SUBMITTED,
} from './BookmarksConstants';
import { STATUS } from '../../constants';

export const initialState = Immutable({});

const sortByName = (a, b) => {
  if (a.name < b.name) {
    return -1;
  }
  if (a.name > b.name) {
    return 1;
  }
  // names must be equal
  return 0;
};

export default (state = initialState, { type, payload, response }) => {
  switch (type) {
    case BOOKMARKS_REQUEST:
      return state.set(payload.controller, {
        results: [],
        errors: null,
        status: STATUS.PENDING,
      });
    case BOOKMARKS_SUCCESS:
      return state
        .setIn([payload.controller, 'results'], response.results)
        .setIn([payload.controller, 'status'], STATUS.RESOLVED);
    case BOOKMARKS_FORM_SUBMITTED:
      return state.setIn(
        [payload.data.controller, 'results'],
        [...state[payload.data.controller].results, payload.data].sort(
          sortByName
        )
      );
    case BOOKMARKS_FAILURE:
      return state
        .setIn([payload.controller, 'errors'], response)
        .setIn([payload.controller, 'status'], STATUS.ERROR);
    default:
      return state;
  }
};
