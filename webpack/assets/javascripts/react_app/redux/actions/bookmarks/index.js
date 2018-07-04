import URI from 'urijs';
import {
  BOOKMARKS_REQUEST,
  BOOKMARKS_SUCCESS,
  BOOKMARKS_FAILURE,
  BOOKMARKS_MODAL_OPENED,
  BOOKMARKS_MODAL_CLOSED,
} from '../../consts';
import { ajaxRequestAction } from '../common';

const _getBookmarks = (url, controller) => dispatch =>
  ajaxRequestAction({
    dispatch,
    requestAction: BOOKMARKS_REQUEST,
    successAction: BOOKMARKS_SUCCESS,
    failedAction: BOOKMARKS_FAILURE,
    url,
    item: { controller },
  });

export const getBookmarks = (url, controller) => {
  const uri = new URI(url);

  // eslint-disable-next-line camelcase
  uri.setSearch({ search: `controller=${controller}`, per_page: 100 });

  return _getBookmarks(uri.toString(), controller);
};

export const modalOpened = query => ({
  type: BOOKMARKS_MODAL_OPENED,
  payload: {
    query,
  },
});

export const modalClosed = () => ({
  type: BOOKMARKS_MODAL_CLOSED,
});
