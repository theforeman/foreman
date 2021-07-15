import PropTypes from 'prop-types';
import React from 'react';
import { Modal, Title, TitleSizes } from '@patternfly/react-core';
import StatusTable from './StatusTable';
import { translate as __ } from '../../../common/I18n';
import { noop } from '../../../common/helpers';

const StatusModal = ({ isOpen, onClose, statuses, hostName }) => {
  const header = (
    <>
      <Title
        id="custom-header-label"
        headingLevel="h1"
        size={TitleSizes['2xl']}
      >
        {__("Manage Host's Statuses")}
      </Title>
      <p className="pf-u-pt-sm">
        {__('List of all the available host sub-statuses')}
      </p>
    </>
  );

  return (
    <Modal
      width="50%"
      isOpen={isOpen}
      aria-label="statuses-modal"
      aria-labelledby="statuses-modal-header"
      aria-describedby="statuses-modal-description"
      header={header}
      onClose={onClose}
      appendTo={document.body}
    >
      <br />
      <StatusTable statuses={statuses} hostName={hostName} />
    </Modal>
  );
};

StatusModal.propTypes = {
  hostName: PropTypes.string,
  isOpen: PropTypes.bool,
  onClose: PropTypes.func,
  statuses: PropTypes.arrayOf(PropTypes.object),
};

StatusModal.defaultProps = {
  hostName: '',
  isOpen: false,
  onClose: noop,
  statuses: [],
};

export default StatusModal;
