import React from 'react';
import { Modal, Icon, Button } from 'patternfly-react';
import PropTypes from 'prop-types';

import DiffView from '../../DiffView/DiffView';
import DiffRadioButtons from '../../DiffView/DiffRadioButtons';

import './diffmodal.scss';

const DiffModal = ({
  title,
  oldText,
  newText,
  diff,
  isOpen,
  toggleModal,
  diffViewType,
  changeViewType,
}) => (
  <Modal show={isOpen} onHide={toggleModal} className="diff-modal">
    <Modal.Header>
      <h4 id="diff-modal-h4">{title}</h4>
      <Button className="close diff-modal-close" onClick={toggleModal} bsStyle="link">
        <Icon type="pf" name="close" />
      </Button>
      <DiffRadioButtons changeState={changeViewType} stateView={diffViewType} />
    </Modal.Header>
    <Modal.Body className="diff-modal-body">
      <div id="diff-table">
        <DiffView oldText={oldText} newText={newText} patch={diff} viewType={diffViewType} />
      </div>
    </Modal.Body>
  </Modal>
);

DiffModal.propTypes = {
  patch: PropTypes.string,
  oldText: PropTypes.string,
  newText: PropTypes.string,
  isOpen: PropTypes.bool.isRequired,
  toggleModal: PropTypes.func.isRequired,
};

DiffModal.defaultProps = {
  patch: '',
  oldText: '',
  newText: '',
};

export default DiffModal;
