import React from 'react';
import PropTypes from 'prop-types';
import { Modal, ModalHeader, ModalBody } from '@patternfly/react-core/next';
import { translate as __ } from '../../common/I18n';
import BookmarkForm from './BookmarkForm';

const SearchModal = ({
  setModalClosed,
  title,
  controller,
  url,
  bookmarks,
  searchQuery,
  isOpened,
}) => (
  <Modal
    variant="small"
    ouiaId="bookmark-modal"
    aria-label="bookmark-modal"
    isOpen={isOpened}
    onClose={setModalClosed}
  >
    <ModalHeader title={title} />
    <ModalBody>
      <BookmarkForm
        controller={controller}
        url={url}
        setModalClosed={setModalClosed}
        onCancel={setModalClosed}
        bookmarks={bookmarks}
        searchQuery={searchQuery}
      />
    </ModalBody>
  </Modal>
);

SearchModal.propTypes = {
  controller: PropTypes.string.isRequired,
  url: PropTypes.string.isRequired,
  title: PropTypes.string,
  setModalClosed: PropTypes.func.isRequired,
  bookmarks: PropTypes.array,
  searchQuery: PropTypes.string.isRequired,
  isOpened: PropTypes.bool.isRequired,
};

SearchModal.defaultProps = {
  title: __('Create Bookmark'),
  bookmarks: [],
};

export default SearchModal;
