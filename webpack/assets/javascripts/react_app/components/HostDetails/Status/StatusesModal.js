import PropTypes from 'prop-types';
import React from 'react';
import { Modal, Title, TitleSizes } from '@patternfly/react-core';
import StatusTable from './StatusTable';
import { translate as __ } from '../../../common/I18n';
import { noop } from '../../../common/helpers';

const StatusModal = ({
  isOpen,
  onClose,
  statuses,
  hostName,
  canForgetStatuses,
}) => {
  const header = (
    <>
      <Title
        id="statuses-modal-header"
        headingLevel="h1"
        size={TitleSizes['2xl']}
      >
        {__("Manage Host's Statuses")}
      </Title>
    </>
  );

  return (
    <Modal
      width="50%"
      aria-label="statuses modal"
      isOpen={isOpen}
      header={header}
      onClose={onClose}
      appendTo={document.body}
    >
      <br />
      <StatusTable
        canForgetStatuses={canForgetStatuses}
        statuses={statuses}
        hostName={hostName}
      />
    </Modal>
  );
};

StatusModal.propTypes = {
  hostName: PropTypes.string.isRequired,
  isOpen: PropTypes.bool,
  onClose: PropTypes.func,
  statuses: PropTypes.arrayOf(PropTypes.object),
  canForgetStatuses: PropTypes.bool,
};

StatusModal.defaultProps = {
  isOpen: false,
  onClose: noop,
  statuses: [],
  canForgetStatuses: undefined,
};

export default StatusModal;
