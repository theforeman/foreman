import React from 'react';
import PropTypes from 'prop-types';
import ForemanModal from '../ForemanModal';
import { translate as __ } from '../../common/I18n';
import { noop } from '../../common/helpers';
import BookmarkForm from './BookmarkForm';
import { getBookmarksModalId } from '../PF4/Bookmarks/BookmarksHelpers';

const SearchModal = ({
  id,
  setModalClosed,
  onEnter,
  title,
  controller,
  url,
  bookmarks,
  searchQuery,
}) => (
  <ForemanModal
    id={getBookmarksModalId(id)}
    title={title}
    enforceFocus
    onEnter={onEnter}
  >
    <BookmarkForm
      id={id}
      controller={controller}
      url={url}
      setModalClosed={setModalClosed}
      onCancel={setModalClosed}
      bookmarks={bookmarks}
      searchQuery={searchQuery}
    />
  </ForemanModal>
);

SearchModal.propTypes = {
  id: PropTypes.string,
  controller: PropTypes.string.isRequired,
  url: PropTypes.string.isRequired,
  title: PropTypes.string,
  onEnter: PropTypes.func,
  setModalClosed: PropTypes.func.isRequired,
  bookmarks: PropTypes.array,
  searchQuery: PropTypes.string.isRequired,
};

SearchModal.defaultProps = {
  id: '',
  title: __('Create Bookmark'),
  onEnter: noop,
  bookmarks: [],
};

export default SearchModal;
