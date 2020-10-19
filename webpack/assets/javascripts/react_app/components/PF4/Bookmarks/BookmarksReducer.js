import Immutable from 'seamless-immutable';
import { BOOKMARKS_FORM_SUBMITTED_SUCCESS } from './BookmarksConstants';

export const initialState = Immutable({});

export default (state = initialState, { type, payload, response }) => {
  switch (type) {
    case BOOKMARKS_FORM_SUBMITTED_SUCCESS:
      return state.setIn(
        [response.controller, 'results'],
        [...(state.results || []), response]
      );
    default:
      return state;
  }
};
