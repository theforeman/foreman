import React, { useContext } from 'react';
import PropTypes from 'prop-types';
import { ForemanActionsBarContext } from '../../../../components/HostDetails/ActionsBar';
import BulkChangeOwnerModal from './BulkChangeOwnerModal';

const BulkChangeOwnerModalScene = ({ isOpen, closeModal }) => {
  const {
    selectAllHostsMode,
    selectedCount,
    selectedResults,
    fetchBulkParams,
    organizationId,
    locationId,
    refreshTableData,
  } = useContext(ForemanActionsBarContext);
  return (
    <BulkChangeOwnerModal
      key="bulk-change-owner-modal"
      selectAllHostsMode={selectAllHostsMode}
      selectedCount={selectedCount}
      selectedResults={selectedResults}
      fetchBulkParams={fetchBulkParams}
      organizationId={organizationId}
      locationId={locationId}
      isOpen={isOpen}
      closeModal={closeModal}
      onSuccess={refreshTableData}
    />
  );
};

export default BulkChangeOwnerModalScene;

BulkChangeOwnerModalScene.propTypes = {
  isOpen: PropTypes.bool.isRequired,
  closeModal: PropTypes.func.isRequired,
};
