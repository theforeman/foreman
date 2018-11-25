import React from 'react';
import { Modal, Icon, Button } from 'patternfly-react';
import PropTypes from 'prop-types';

import { noop } from '../../../common/helpers';
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
      <Button
        className="close diff-modal-close"
        onClick={toggleModal}
        bsStyle="link"
      >
        <Icon type="pf" name="close" />
      </Button>
      <DiffRadioButtons changeState={changeViewType} stateView={diffViewType} />
    </Modal.Header>
    <Modal.Body className="diff-modal-body">
      <div id="diff-table">
        <DiffView
          oldText={oldText}
          newText={newText}
          patch={diff}
          viewType={diffViewType}
        />
      </div>
    </Modal.Body>
  </Modal>
);

DiffModal.propTypes = {
  title: PropTypes.string,
  diff: PropTypes.string,
  oldText: PropTypes.string,
  newText: PropTypes.string,
  diffViewType: PropTypes.oneOf(['split', 'unified']),
  isOpen: PropTypes.bool,
  changeViewType: PropTypes.func,
  toggleModal: PropTypes.func,
};

DiffModal.defaultProps = {
  title: '',
  diff: '',
  oldText: '',
  newText: '',
  diffViewType: 'split',
  isOpen: false,
  changeViewType: noop,
  toggleModal: noop,
};

export default DiffModal;
