import immutable from 'seamless-immutable';
import {
  BOOKMARKS_REQUEST,
  BOOKMARKS_SUCCESS,
  BOOKMARKS_FAILURE,
} from '../../consts';
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

const APIMiddlewareAction = {
  key: 'BOOKMARKS',
  payload: { controller: 'hosts' },
  type: 'API_GET',
  url: '/api/bookmarks?search=controller%3Dhosts&per_page=100',
};

const requestAction = {
  type: BOOKMARKS_REQUEST,
  payload: { controller: 'hosts' },
};

export const onFailureActions = [
  requestAction,
  APIMiddlewareAction,
  {
    payload: {
      error: new Error('Request failed with status code 422'),
      payload: { controller: 'hosts' },
    },
    type: BOOKMARKS_FAILURE,
  },
];

export const onSuccessActions = [
  requestAction,
  APIMiddlewareAction,
  {
    payload: {
      controller: 'hosts',
      results: bookmarks,
    },
    type: BOOKMARKS_SUCCESS,
  },
];
