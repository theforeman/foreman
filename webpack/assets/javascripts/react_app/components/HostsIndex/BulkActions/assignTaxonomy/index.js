import React, { useContext } from 'react';
import PropTypes from 'prop-types';
import { ForemanActionsBarContext } from '../../../../components/HostDetails/ActionsBar';
import {
  BulkAssignOrganizationModal,
  BulkAssignLocationModal,
} from './BulkAssignTaxonomyModal';

export const BulkAssignOrganizationModalScene = ({ isOpen, closeModal }) => {
  const { selectAllHostsMode, selectedCount, fetchBulkParams } = useContext(
    ForemanActionsBarContext
  );
  return (
    <BulkAssignOrganizationModal
      key="bulk-assign-organization-modal"
      selectAllHostsMode={selectAllHostsMode}
      selectedCount={selectedCount}
      fetchBulkParams={fetchBulkParams}
      isOpen={isOpen}
      closeModal={closeModal}
    />
  );
};

export const BulkAssignLocationModalScene = ({ isOpen, closeModal }) => {
  const { selectAllHostsMode, selectedCount, fetchBulkParams } = useContext(
    ForemanActionsBarContext
  );
  return (
    <BulkAssignLocationModal
      key="bulk-assign-location-modal"
      selectAllHostsMode={selectAllHostsMode}
      selectedCount={selectedCount}
      fetchBulkParams={fetchBulkParams}
      isOpen={isOpen}
      closeModal={closeModal}
    />
  );
};

BulkAssignOrganizationModalScene.propTypes = {
  isOpen: PropTypes.bool.isRequired,
  closeModal: PropTypes.func.isRequired,
};

BulkAssignLocationModalScene.propTypes = {
  isOpen: PropTypes.bool.isRequired,
  closeModal: PropTypes.func.isRequired,
};
