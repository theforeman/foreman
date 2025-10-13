import React from 'react';
import PropTypes from 'prop-types';
import { Modal, Progress } from '@patternfly/react-core';
import { sprintf, translate as __ } from '../../../common/I18n';
import './ModalProgressBar.scss';

const ModalProgressBar = ({ show, container, title, progress }) => (
  <Modal
    id="modal-progress-bar"
    ouiaId="modal-progress-bar"
    variant="small"
    isOpen={show}
    aria-label={title || 'modal-progress-bar'}
    appendTo={container}
    title={title}
    disableFocusTrap
    showClose={false}
  >
    <Progress
      value={progress}
      label={sprintf(__('%s%% Complete'), progress)}
      aria-label="progress-bar"
    />
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
