import Immutable from 'seamless-immutable';

import {
  AUDITS_PAGE_SHOW_MESSAGE,
  AUDITS_PAGE_HIDE_MESSAGE,
  AUDITS_PAGE_SHOW_LOADING,
  AUDITS_PAGE_HIDE_LOADING,
  AUDITS_PAGE_FETCH,
  AUDITS_PAGE_CHANGE_PARAMS,
  AUDITS_PAGE_NEXT_PENDING,
  AUDITS_PAGE_NEXT_RESOLVED,
  AUDITS_PAGE_PREV_PENDING,
  AUDITS_PAGE_PREV_RESOLVED,
  AUDITS_PAGE_CLEAR_CACHE,
  AUDITS_PREV,
  AUDITS_CURRENT,
  AUDITS_NEXT,
} from './AuditsPageConstants';

const initialState = Immutable({
  [AUDITS_NEXT]: [],
  [AUDITS_CURRENT]: [],
  [AUDITS_PREV]: [],
  page: 1,
  perPage: 20,
  searchQuery: '',
  itemCount: 0,
  message: {},
  showMessage: false,
  isLoading: false,
  isFetchingNext: false,
  isFetchingPrev: false,
});

export default (state = initialState, action) => {
  const { payload, type } = action;

  switch (type) {
    case AUDITS_PAGE_FETCH:
      return state.merge(payload);
    case AUDITS_PAGE_CHANGE_PARAMS:
      return state.merge(payload);
    case AUDITS_PAGE_SHOW_MESSAGE:
      return state.merge(payload);
    case AUDITS_PAGE_SHOW_LOADING:
      return state.set('isLoading', true);
    case AUDITS_PAGE_HIDE_LOADING:
      return state.set('isLoading', false);
    case AUDITS_PAGE_NEXT_PENDING:
      return state.set('isFetchingNext', true);
    case AUDITS_PAGE_NEXT_RESOLVED:
      return state.set('isFetchingNext', false);
    case AUDITS_PAGE_PREV_PENDING:
      return state.set('isFetchingPrev', true);
    case AUDITS_PAGE_PREV_RESOLVED:
      return state.set('isFetchingPrev', false);
    case AUDITS_PAGE_CLEAR_CACHE:
      return state.set(AUDITS_NEXT, []).set(AUDITS_PREV, []);
    case AUDITS_PAGE_HIDE_MESSAGE:
      return state.set('showMessage', false).set('message', {});

    default:
      return state;
  }
};
