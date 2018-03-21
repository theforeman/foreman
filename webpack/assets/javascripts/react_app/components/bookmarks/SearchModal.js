import React from 'react';
import { Modal } from 'patternfly-react';
import BookmarkForm from './form';
import { translate as __ } from '../../../react_app/common/I18n';

export default ({
  show = true,
  onHide,
  onEnter,
  title = __('Create Bookmark'),
  controller,
  url,
}) => (
  <Modal show={show} enforceFocus={true} onHide={onHide} onEnter={onEnter}>
    <Modal.Header closeButton={true}>
      <Modal.Title>{title}</Modal.Title>
    </Modal.Header>
    <Modal.Body>
      <BookmarkForm controller={controller} url={url} onCancel={onHide} />
    </Modal.Body>
  </Modal>
);
