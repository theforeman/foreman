import Immutable from 'seamless-immutable';

import {
  AUDITS_PAGE_SHOW_MESSAGE,
  AUDITS_PAGE_HIDE_MESSAGE,
  AUDITS_PAGE_FETCH,
} from './AuditsPageConstants';

const initialState = Immutable({
  audits: [],
  page: 1,
  perPage: 20,
  itemCount: 0,
  showMessage: false,
  message: {},
  searchQuery: '',
});

export default (state = initialState, action) => {
  const { payload, type } = action;

  switch (type) {
    case AUDITS_PAGE_FETCH:
      return state.merge(payload);
    case AUDITS_PAGE_SHOW_MESSAGE:
      return state.merge(payload);
    case AUDITS_PAGE_HIDE_MESSAGE:
      return state.set('showMessage', false).set('message', {});

    default:
      return state;
  }
};
