import React, { useContext } from 'react';
import { ForemanActionsBarContext } from '../../../../components/HostDetails/ActionsBar';
import { useForemanModal } from '../../../../components/ForemanModal/ForemanModalHooks';
import {
  BulkAssignOrganizationModal,
  BulkAssignLocationModal,
} from './BulkAssignTaxonomyModal';

export const BulkAssignOrganizationModalScene = () => {
  const { selectAllHostsMode, selectedCount, fetchBulkParams } = useContext(
    ForemanActionsBarContext
  );
  const { modalOpen, setModalClosed } = useForemanModal({
    id: 'bulk-assign-organization-modal',
  });
  return (
    <BulkAssignOrganizationModal
      key="bulk-assign-organization-modal"
      selectAllHostsMode={selectAllHostsMode}
      selectedCount={selectedCount}
      fetchBulkParams={fetchBulkParams}
      isOpen={modalOpen}
      closeModal={setModalClosed}
    />
  );
};

export const BulkAssignLocationModalScene = () => {
  const { selectAllHostsMode, selectedCount, fetchBulkParams } = useContext(
    ForemanActionsBarContext
  );
  const { modalOpen, setModalClosed } = useForemanModal({
    id: 'bulk-assign-location-modal',
  });
  return (
    <BulkAssignLocationModal
      key="bulk-assign-location-modal"
      selectAllHostsMode={selectAllHostsMode}
      selectedCount={selectedCount}
      fetchBulkParams={fetchBulkParams}
      isOpen={modalOpen}
      closeModal={setModalClosed}
    />
  );
};
