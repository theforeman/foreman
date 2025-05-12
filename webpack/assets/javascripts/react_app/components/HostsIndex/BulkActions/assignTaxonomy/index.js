import React, { useContext } from 'react';
import { ForemanActionsBarContext } from '../../../../components/HostDetails/ActionsBar';
import { useForemanModal } from '../../../../components/ForemanModal/ForemanModalHooks';
import BulkAssignTaxonomyModal from './BulkAssignTaxonomyModal';

const BulkAssignTaxonomyModalScene = () => {
  const { selectedCount, fetchBulkParams } = useContext(
    ForemanActionsBarContext
  );
  const { modalOpen, setModalClosed } = useForemanModal({
    id: 'bulk-assign-taxonomy-modal',
  });
  return (
    <BulkAssignTaxonomyModal
      key="bulk-assign-taxonomy-modal"
      selectedCount={selectedCount}
      fetchBulkParams={fetchBulkParams}
      isOpen={modalOpen}
      closeModal={setModalClosed}
    />
  );
};

export default BulkAssignTaxonomyModalScene;
