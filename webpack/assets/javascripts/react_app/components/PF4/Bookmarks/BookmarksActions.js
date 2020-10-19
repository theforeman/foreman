import URI from 'urijs';
import { get } from '../../../redux/API';
import { BOOKMARKS } from './BookmarksConstants';

export const getBookmarks = (url, controller) => {
  const uri = new URI(url);
  // eslint-disable-next-line camelcase
  uri.setSearch({ search: `controller=${controller}`, per_page: 'all' });

  return get({
    url: uri.toString(),
    key: `${BOOKMARKS}_${controller.toUpperCase()}`,
  });
};
