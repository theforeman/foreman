import Immutable from 'seamless-immutable';
import {
  BOOKMARKS_REQUEST,
  BOOKMARKS_SUCCESS,
  BOOKMARKS_FAILURE,
  BOOKMARKS_MODAL_OPENED,
  BOOKMARKS_MODAL_CLOSED,
  BOOKMARK_FORM_SUBMITTED,
} from '../../consts';

const initialState = Immutable({
  showModal: false,
});

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

export default (state = initialState, action) => {
  const { payload } = action;

  switch (action.type) {
    case BOOKMARKS_REQUEST:
      return state.set(payload.controller, { results: [], errors: null });
    case BOOKMARKS_SUCCESS:
      return state.setIn([payload.controller, 'results'], payload.results);
    case BOOKMARKS_MODAL_OPENED:
      return state.set('currentQuery', payload.query).set('showModal', true);
    case BOOKMARK_FORM_SUBMITTED:
      return state
        .setIn(
          [payload.body.controller, 'results'],
          [...state[payload.body.controller].results, payload.body].sort(sortByName),
        )
        .set('showModal', false);
    case BOOKMARKS_MODAL_CLOSED:
      return state.set('showModal', false);
    case BOOKMARKS_FAILURE:
      return state.setIn([payload.controller, 'errors'], payload.error);
    default:
      return state;
  }
};
