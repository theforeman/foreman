import immutable from 'seamless-immutable';
import { BOOKMARKS_REQUEST, BOOKMARKS_SUCCESS } from '../../consts';
import { bookmarks } from '../../reducers/bookmarks/bookmarks.fixtures';

export const initialState = immutable({
  bookmarks: {
    hosts: { errors: null, results: [] },
    showModal: false,
  },
});

export const requestData = {
  url: '/api/bookmarks',
  searchRegex: /\/api\/bookmarks\?search=.{13}hosts/,
  controller: 'hosts',
  response: { results: bookmarks },
};

const requestAction = {
  type: BOOKMARKS_REQUEST,
  payload: { controller: 'hosts' },
};

const apiAction = {
  key: 'BOOKMARKS',
  payload: { controller: 'hosts' },
  type: 'API_GET',
  url: '/api/bookmarks?search=controller%3Dhosts&per_page=100',
};

export const onFailureActions = [
  requestAction,
  apiAction,
  {
    payload: {
      error: new Error('Request failed with status code 422'),
      payload: { controller: 'hosts' },
    },
    type: 'BOOKMARKS_FAILURE',
  },
];

export const onSuccessActions = [
  requestAction,
  apiAction,
  {
    payload: {
      results: bookmarks,
      controller: 'hosts',
    },
    type: BOOKMARKS_SUCCESS,
  },
];
