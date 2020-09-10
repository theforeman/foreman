import React from 'react';
import PropTypes from 'prop-types';
import ForemanModal from '../../ForemanModal';
import { BOOKMARKS_MODAL } from '../BookmarksConstants';
import { translate as __ } from '../../../common/I18n';
import { noop } from '../../../common/helpers';
import BookmarkForm from './BookmarkForm';

const SearchModal = ({ setModalClosed, onEnter, title, controller, url }) => (
  <ForemanModal
    id={BOOKMARKS_MODAL}
    title={title}
    enforceFocus
    onEnter={onEnter}
  >
    <BookmarkForm
      controller={controller}
      url={url}
      setModalClosed={setModalClosed}
      onCancel={setModalClosed}
    />
  </ForemanModal>
);

SearchModal.propTypes = {
  controller: PropTypes.string.isRequired,
  url: PropTypes.string.isRequired,
  title: PropTypes.string,
  onEnter: PropTypes.func,
  setModalClosed: PropTypes.func.isRequired,
};

SearchModal.defaultProps = {
  title: __('Create Bookmark'),
  onEnter: noop,
};

export default SearchModal;
