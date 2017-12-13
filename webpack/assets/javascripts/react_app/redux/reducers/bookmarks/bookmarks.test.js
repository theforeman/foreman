import reducer from './index';
import * as types from '../../consts';
import {
  initialState,
  afterRequest,
  afterSuccess,
  afterError,
  bookmarks,
  afterModalOpen,
} from './bookmarks.fixtures';

describe('bookmark reducers', () => {
  it('initial state', () => {
    expect(reducer(undefined, {})).toEqual(initialState);
  });
  it('should handle BOOKMARKS_REQUEST action', () => {
    expect(reducer(initialState, {
      type: types.BOOKMARKS_REQUEST,
      payload: { controller: 'hosts' },
    })).toEqual(afterRequest);
  });
  it('should set bookmarks on BOOKMARKS_SUCCESS action', () => {
    expect(reducer(afterRequest, {
      type: types.BOOKMARKS_SUCCESS,
      payload: { controller: 'hosts', results: bookmarks },
    })).toEqual(afterSuccess);
  });
  it('should set error state on BOOKMARKS_FAILURE action', () => {
    expect(reducer(afterRequest, {
      type: types.BOOKMARKS_FAILURE,
      payload: { item: { controller: 'hosts' }, error: 'Oops' },
    })).toEqual(afterError);
  });
  it('should set form query on BOOKMARKS_MODAL_OPENED', () => {
    expect(reducer(afterSuccess, {
      type: types.BOOKMARKS_MODAL_OPENED,
      payload: { query: 'hosts ~ awesome' },
    })).toEqual(afterModalOpen);
  });
  it('should close modal on BOOKMARKS_MODAL_CLOSED', () => {
    expect(reducer(afterModalOpen, {
      type: types.BOOKMARKS_MODAL_CLOSED,
    })).toEqual({ ...afterModalOpen, showModal: false });
  });
  it('should add bookmark to state on BOOKMARK_FORM_SUBMITTED', () => {
    const state = reducer(afterModalOpen, {
      type: types.BOOKMARK_FORM_SUBMITTED,
      payload: {
        item: 'Bookmark',
        data: {
          name: '0test-me',
          controller: 'hosts',
          query: 'mac~aabbccd',
          public: true,
          id: 67,
        },
      },
    });

    expect(state.hosts.results.length).toEqual(bookmarks.length + 1);
    expect(state.hosts.results[0].name).toEqual('0test-me');
  });
});
