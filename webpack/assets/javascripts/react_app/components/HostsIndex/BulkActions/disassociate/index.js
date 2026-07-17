import React, { useContext } from 'react';
import PropTypes from 'prop-types';
import { ForemanActionsBarContext } from '../../../../components/HostDetails/ActionsBar';
import BulkDisassociateModal from './BulkDisassociateModal';

const BulkDisassociateModalScene = ({ isOpen, closeModal }) => {
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
    <BulkDisassociateModal
      key="bulk-disassociate-modal"
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

export default BulkDisassociateModalScene;

BulkDisassociateModalScene.propTypes = {
  isOpen: PropTypes.bool.isRequired,
  closeModal: PropTypes.func.isRequired,
};
