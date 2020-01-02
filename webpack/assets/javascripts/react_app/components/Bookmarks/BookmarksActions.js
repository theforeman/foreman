import URI from 'urijs';
import {
  BOOKMARKS,
  BOOKMARKS_MODAL_OPENED,
  BOOKMARKS_MODAL_CLOSED,
} from './BookmarksConstants';
import { get } from '../../redux/API';

const _getBookmarks = (url, controller) =>
  get({
    key: BOOKMARKS,
    url,
    payload: { controller },
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
