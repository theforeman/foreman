import { testReducerSnapshotWithFixtures } from '@theforeman/test';
import Immutable from 'seamless-immutable';

import reducer, { initialState } from '../BookmarksReducer';
import { STATUS } from '../../../constants';

import {
  BOOKMARKS_REQUEST,
  BOOKMARKS_SUCCESS,
  BOOKMARKS_FAILURE,
  BOOKMARKS_FORM_SUBMITTED,
} from '../BookmarksConstants';

const stateFactory = (nestedState = {}) =>
  Immutable.merge(initialState, {
    architectures: {
      results: [],
      errors: null,
      status: STATUS.PENDING,
      ...nestedState,
    },
  });

const bookmarkItem = {
  name: 'my bookmark',
  query: 'name ~ random',
  controller: 'architectures',
};

const fixtures = {
  'should return initial state': {
    state: stateFactory(),
    action: {
      type: undefined,
      payload: {},
    },
  },
  'should start loading on bookmarks request': {
    state: stateFactory({ status: STATUS.RESOLVED }),
    action: {
      type: BOOKMARKS_REQUEST,
      payload: {
        controller: 'architectures',
      },
    },
  },
  'should stop loading on bookmarks success': {
    state: stateFactory(),
    action: {
      type: BOOKMARKS_SUCCESS,
      payload: {
        controller: 'architectures',
      },
      response: {
        results: [bookmarkItem],
      },
    },
  },
  'should show errors': {
    state: stateFactory(),
    action: {
      type: BOOKMARKS_FAILURE,
      payload: {
        controller: 'architectures',
      },
      response: 'This is error',
    },
  },
  'should update after form submission': {
    state: stateFactory({ status: STATUS.RESOLVED }),
    action: {
      type: BOOKMARKS_FORM_SUBMITTED,
      payload: {
        data: {
          name: 'new bookmark',
          controller: 'architectures',
          query: 'random query',
          public: true,
          id: 42,
        },
        item: 'Bookmark',
      },
    },
  },
};

describe('BookmarksReducer', () =>
  testReducerSnapshotWithFixtures(reducer, fixtures));
