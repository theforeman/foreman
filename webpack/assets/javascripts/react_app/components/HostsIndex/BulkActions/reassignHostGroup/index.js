import React, { useContext } from 'react';
import { ForemanActionsBarContext } from '../../../../components/HostDetails/ActionsBar';
import { useForemanModal } from '../../../../components/ForemanModal/ForemanModalHooks';
import BulkReassignHostgroupModal from './BulkReassignHostgroupModal';

const BulkReassignHostgroupModalScene = () => {
  const { selectedCount, fetchBulkParams } = useContext(
    ForemanActionsBarContext
  );
  const { modalOpen, setModalClosed } = useForemanModal({
    id: 'bulk-reassign-hg-modal',
  });
  return (
    <BulkReassignHostgroupModal
      key="bulk-reassign-hg-modal"
      selectedCount={selectedCount}
      fetchBulkParams={fetchBulkParams}
      isOpen={modalOpen}
      closeModal={setModalClosed}
    />
  );
};

export default BulkReassignHostgroupModalScene;
