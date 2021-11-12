import { BOOKMARKS_MODAL } from './BookmarksConstants';

export const getBookmarksModalId = id =>
  id ? `${BOOKMARKS_MODAL}-${id}` : BOOKMARKS_MODAL;
