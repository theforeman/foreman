import immutable from 'seamless-immutable';
import * as types from '../../consts';
import { bookmarks } from '../../reducers/bookmarks/bookmarks.fixtures';

export const initialState = immutable({
  bookmarks: {
    hosts: { errors: null, results: [] },
    showModal: false,
  },
});

export const requestData = { url: '/api/bookmarks', controller: 'hosts' };

const requestAction = {
  type: types.BOOKMARKS_REQUEST,
  payload: { controller: 'hosts' },
};

export const onFailureActions = [
  requestAction,
  {
    payload: { error: {}, item: { controller: 'hosts' } },
    type: types.BOOKMARKS_FAILURE,
  },
];

export const onSuccessActions = [
  requestAction,
  {
    payload: {
      results: bookmarks,
      controller: 'hosts',
    },
    type: types.BOOKMARKS_SUCCESS,
  },
];
