/* eslint-disable camelcase */
import Immutable from 'seamless-immutable';
import { STATUS } from '../../constants';

export const initialState = Immutable({
  bookmarks: {
    showModal: false,
  },
});
export const bookmarks = [
  {
    name: '1111',
    controller: 'hosts',
    query: 'abc',
    public: true,
    id: 52,
    owner_id: 1,
    owner_type: 'User',
  },
  {
    name: '1122',
    controller: 'hosts',
    query: 'abc',
    public: true,
    id: 54,
    owner_id: 1,
    owner_type: 'User',
  },
];

export const afterRequest = Immutable({
  bookmarks: {
    ...initialState,
    hosts: { errors: null, results: [], status: STATUS.PENDING },
  },
});

export const afterSuccess = Immutable({
  bookmarks: {
    ...initialState,
    hosts: { errors: null, results: bookmarks, status: STATUS.RESOLVED },
  },
});

export const afterSuccessNoResults = Immutable({
  bookmarks: {
    ...initialState,
    hosts: { errors: null, results: [], status: STATUS.RESOLVED },
  },
});

export const afterError = Immutable({
  bookmarks: {
    ...initialState,
    hosts: { errors: 'Oops', results: [], status: STATUS.ERROR },
  },
});
