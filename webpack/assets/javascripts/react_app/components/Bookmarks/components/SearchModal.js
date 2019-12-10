import React from 'react';
import PropTypes from 'prop-types';
import { Modal } from 'patternfly-react';

import { noop } from '../../../common/helpers';
import BookmarkForm from './BookmarkForm';
import { translate as __ } from '../../../../react_app/common/I18n';

const SearchModal = ({ show, onHide, onEnter, title, controller, url }) => (
  <Modal show={show} enforceFocus onHide={onHide} onEnter={onEnter}>
    <Modal.Header closeButton>
      <Modal.Title>{title}</Modal.Title>
    </Modal.Header>
    <Modal.Body>
      <BookmarkForm controller={controller} url={url} onCancel={onHide} />
    </Modal.Body>
  </Modal>
);

SearchModal.propTypes = {
  controller: PropTypes.string.isRequired,
  url: PropTypes.string.isRequired,
  show: PropTypes.bool,
  title: PropTypes.string,
  onHide: PropTypes.func,
  onEnter: PropTypes.func,
};

SearchModal.defaultProps = {
  show: true,
  title: __('Create Bookmark'),
  onHide: noop,
  onEnter: noop,
};

export default SearchModal;
