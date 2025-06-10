import React from 'react';
import { useSelector, useDispatch } from 'react-redux';
import PropTypes from 'prop-types';
import { getBookmarks } from './BookmarksActions';
import { BOOKMARKS } from './BookmarksConstants';
import Bookmarks from './Bookmarks';

import reducer from './BookmarksReducer';
import {
  selectAPIStatus,
  selectAPIError,
} from '../../../redux/API/APISelectors';
import { selectBookmarksResults } from './BookmarksSelectors';

const ConnectedBookmarks = ({
  id,
  controller,
  onBookmarkClick,
  url,
  canCreate,
  documentationUrl,
  searchQuery,
  bookmarksPosition,
}) => {
  const key = `${BOOKMARKS}_${controller.toUpperCase()}`;
  const status = useSelector(store => selectAPIStatus(store, key));
  const errors = useSelector(store => selectAPIError(store, key));
  const bookmarks = useSelector(store =>
    selectBookmarksResults(store, key, controller)
  );
  const dispatch = useDispatch();
  return (
    <Bookmarks
      id={id}
      bookmarks={bookmarks}
      status={status}
      url={url}
      controller={controller}
      getBookmarks={() => dispatch(getBookmarks(url, controller))}
      canCreate={canCreate}
      errors={errors}
      documentationUrl={documentationUrl}
      onBookmarkClick={onBookmarkClick}
      searchQuery={searchQuery}
      bookmarksPosition={bookmarksPosition}
    />
  );
};

ConnectedBookmarks.propTypes = {
  id: PropTypes.string,
  controller: PropTypes.string.isRequired,
  onBookmarkClick: PropTypes.func.isRequired,
  url: PropTypes.string.isRequired,
  canCreate: PropTypes.bool,
  documentationUrl: PropTypes.string,
  searchQuery: PropTypes.string,
  bookmarksPosition: PropTypes.string,
};

ConnectedBookmarks.defaultProps = {
  id: 'searchBar',
  canCreate: false,
  documentationUrl: '',
  searchQuery: '',
  bookmarksPosition: 'left',
};

export const reducers = { bookmarksPF4: reducer };
export default ConnectedBookmarks;
