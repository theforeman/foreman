import URI from 'urijs';
import { get } from '../../redux/API';
import { BOOKMARKS } from './BookmarksConstants';

const _getBookmarks = (url, controller) =>
  get({
    key: BOOKMARKS,
    url,
    payload: { controller },
  });

export const getBookmarks = (url, controller) => {
  const uri = new URI(url);

  // eslint-disable-next-line camelcase
  uri.setSearch({ search: `controller=${controller}`, per_page: 'all' });

  return _getBookmarks(uri.toString(), controller);
};
