import React from 'react';
import { useSelector, useDispatch } from 'react-redux';
import PropTypes from 'prop-types';
import { getBookmarks } from './BookmarksActions';
import { BOOKMARKS_MODAL, BOOKMARKS } from './BookmarksConstants';
import { useForemanModal } from '../../ForemanModal/ForemanModalHooks';
import { selectIsModalOpen } from '../../ForemanModal/ForemanModalSelectors';
import Bookmarks from './Bookmarks';

import reducer from './BookmarksReducer';
import {
  selectAPIStatus,
  selectAPIError,
} from '../../../redux/API/APISelectors';
import { selectBookmarksResults } from './BookmarksSelectors';

const ConnectedBookmarks = ({
  controller,
  onBookmarkClick,
  url,
  canCreate,
  documentationUrl,
}) => {
  const key = `${BOOKMARKS}_${controller.toUpperCase()}`;
  const status = useSelector((store) => selectAPIStatus(store, key));
  const errors = useSelector((store) => selectAPIError(store, key));
  const bookmarks = useSelector((store) =>
    selectBookmarksResults(store, key, controller)
  );
  const isModalOpen = useSelector((store) =>
    selectIsModalOpen(store, BOOKMARKS_MODAL)
  );
  const dispatch = useDispatch();

  const { setModalOpen, setModalClosed } = useForemanModal({
    id: BOOKMARKS_MODAL,
  });
  return (
    <Bookmarks
      bookmarks={bookmarks}
      status={status}
      url={url}
      controller={controller}
      getBookmarks={() => dispatch(getBookmarks(url, controller))}
      canCreate={canCreate}
      errors={errors}
      documentationUrl={documentationUrl}
      onBookmarkClick={onBookmarkClick}
      setModalOpen={setModalOpen}
      setModalClosed={setModalClosed}
      isModalOpen={isModalOpen}
    />
  );
};

ConnectedBookmarks.propTypes = {
  controller: PropTypes.string.isRequired,
  onBookmarkClick: PropTypes.func.isRequired,
  url: PropTypes.string.isRequired,
  canCreate: PropTypes.bool,
  documentationUrl: PropTypes.string,
};

ConnectedBookmarks.defaultProps = {
  canCreate: false,
  documentationUrl: '',
};

export const reducers = { bookmarksPF4: reducer };
export default ConnectedBookmarks;
