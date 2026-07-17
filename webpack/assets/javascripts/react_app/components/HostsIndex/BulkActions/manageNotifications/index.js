import React, { useContext } from 'react';
import PropTypes from 'prop-types';
import { ForemanActionsBarContext } from '../../../../components/HostDetails/ActionsBar';
import BulkManageNotificationsModal from './BulkManageNotificationsModal';

const BulkManageNotificationsModalScene = ({ isOpen, closeModal }) => {
  const { fetchBulkParams, selectedCount = 0, refreshTableData } = useContext(
    ForemanActionsBarContext
  );
  return (
    <BulkManageNotificationsModal
      selectedCount={selectedCount}
      fetchBulkParams={fetchBulkParams}
      isOpen={isOpen}
      closeModal={closeModal}
      onSuccess={refreshTableData}
    />
  );
};

export default BulkManageNotificationsModalScene;

BulkManageNotificationsModalScene.propTypes = {
  isOpen: PropTypes.bool.isRequired,
  closeModal: PropTypes.func.isRequired,
};
