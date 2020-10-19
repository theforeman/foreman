import { selectAPIResponse } from '../../../redux/API/APISelectors';

const sortByName = (a, b) => {
  if (a.name < b.name) {
    return -1;
  }
  if (a.name > b.name) {
    return 1;
  }
  // names must be equal
  return 0;
};
const selectBookmarks = state => state.bookmarksPF4 || {};
const selectBookmarksByController = (state, controller) =>
  selectBookmarks(state)[controller] || {};

export const selectBookmarksResults = (store, key, controller) =>
  [
    ...(selectBookmarksByController(store, controller).results || []),
    ...(selectAPIResponse(store, key).results || []),
  ].sort(sortByName);
