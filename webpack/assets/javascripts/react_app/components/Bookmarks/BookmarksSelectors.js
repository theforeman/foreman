const selectBookmarkState = state => state.bookmarks;

const selectBookmarksSubState = (state, controller) =>
  selectBookmarkState(state)[controller];

const selectBookmarksStateByController = (
  state,
  controller,
  attr,
  defaultValue
) => {
  const bookmarksState = selectBookmarksSubState(state, controller);
  return bookmarksState ? bookmarksState[attr] : defaultValue;
};

export const selectBookmarksStatus = (state, controller) =>
  selectBookmarksStateByController(state, controller, 'status', 'RESOLVED');

export const selectBookmarksResults = (state, controller) =>
  selectBookmarksStateByController(state, controller, 'results', []);

export const selectBookmarksErrors = (state, controller) =>
  selectBookmarksStateByController(state, controller, 'errors', null);
