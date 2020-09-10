import React from 'react';
import PropTypes from 'prop-types';
import { Modal, ProgressBar } from 'patternfly-react';
import { sprintf, translate as __ } from '../../../common/I18n';
import './ModalProgressBar.scss';

const ModalProgressBar = ({ show, container, title, progress }) => (
  <Modal id="modal-progress-bar" show={show} container={container}>
    <Modal.Header>
      <Modal.Title>{title}</Modal.Title>
    </Modal.Header>
    <Modal.Body>
      <ProgressBar
        active
        now={progress}
        label={sprintf(__(`${progress}%% Complete`))}
      />
    </Modal.Body>
  </Modal>
);

ModalProgressBar.propTypes = {
  show: PropTypes.bool.isRequired,
  container: PropTypes.shape({}),
  title: PropTypes.string,
  progress: PropTypes.number,
};

ModalProgressBar.defaultProps = {
  container: document.body,
  title: null,
  progress: 0,
};

export default ModalProgressBar;
