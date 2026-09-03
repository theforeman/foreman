import React, { useContext } from 'react';
import PropTypes from 'prop-types';
import { ForemanActionsBarContext } from '../../../../components/HostDetails/ActionsBar';
import BulkEditParametersModal from './BulkEditParametersModal';

const BulkEditParametersModalScene = ({ isOpen, closeModal }) => {
  const {
    selectedCount = 0,
    fetchBulkParams,
    organizationId,
    locationId,
    refreshTableData,
  } = useContext(ForemanActionsBarContext);
  return (
    <BulkEditParametersModal
      selectedCount={selectedCount}
      fetchBulkParams={fetchBulkParams}
      organizationId={organizationId}
      locationId={locationId}
      isOpen={isOpen}
      closeModal={closeModal}
      onSuccess={refreshTableData}
    />
  );
};

export default BulkEditParametersModalScene;

BulkEditParametersModalScene.propTypes = {
  isOpen: PropTypes.bool.isRequired,
  closeModal: PropTypes.func.isRequired,
};
