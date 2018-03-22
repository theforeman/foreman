import Immutable from 'seamless-immutable';
import {
  BOOKMARKS_REQUEST,
  BOOKMARKS_SUCCESS,
  BOOKMARKS_FAILURE,
  BOOKMARKS_MODAL_OPENED,
  BOOKMARKS_MODAL_CLOSED,
  BOOKMARK_FORM_SUBMITTED,
} from '../../consts';
import { STATUS } from '../../../constants';

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
      return state.set(payload.controller, { results: [], errors: null, status: STATUS.PENDING });
    case BOOKMARKS_SUCCESS:
      return state
        .setIn([payload.controller, 'results'], payload.results)
        .setIn([payload.controller, 'status'], STATUS.RESOLVED);
    case BOOKMARKS_MODAL_OPENED:
      return state.set('currentQuery', payload.query).set('showModal', true);
    case BOOKMARK_FORM_SUBMITTED:
      return state
        .setIn(
          [payload.data.controller, 'results'],
          [...state[payload.data.controller].results, payload.data].sort(sortByName),
        )
        .set('showModal', false);
    case BOOKMARKS_MODAL_CLOSED:
      return state.set('showModal', false);
    case BOOKMARKS_FAILURE:
      return state
        .setIn([payload.item.controller, 'errors'], payload.error)
        .setIn([payload.item.controller, 'status'], STATUS.ERROR);
    default:
      return state;
  }
};
