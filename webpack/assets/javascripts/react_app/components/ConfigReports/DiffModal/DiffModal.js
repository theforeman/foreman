import React from 'react';
import { Modal } from '@patternfly/react-core';
import PropTypes from 'prop-types';

import { noop } from '../../../common/helpers';
import { translate as __ } from '../../../common/I18n';
import DiffView from '../../DiffView/DiffView';
import DiffToggle from '../../DiffView/DiffToggle';

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
  <Modal
    isOpen={isOpen}
    onClose={toggleModal}
    ouiaId="diff-modal"
    position="top"
    variant="large"
    title={title || __('Show Diff')}
    actions={[
      <DiffToggle
        changeState={changeViewType}
        stateView={diffViewType}
        key="diff-toggle"
      />,
    ]}
  >
    <div id="diff-table">
      <DiffView
        oldText={oldText}
        newText={newText}
        patch={diff}
        viewType={diffViewType}
      />
    </div>
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
