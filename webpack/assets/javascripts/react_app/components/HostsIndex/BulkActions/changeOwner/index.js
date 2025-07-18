import React, { useContext } from 'react';
import { ForemanActionsBarContext } from '../../../../components/HostDetails/ActionsBar';
import { useForemanModal } from '../../../../components/ForemanModal/ForemanModalHooks';
import BulkChangeOwnerModal from './BulkChangeOwnerModal';

const BulkChangeOwnerModalScene = () => {
  const {
    selectAllHostsMode,
    selectedCount,
    selectedResults,
    fetchBulkParams,
  } = useContext(ForemanActionsBarContext);
  const { modalOpen, setModalClosed } = useForemanModal({
    id: 'bulk-change-owner-modal',
  });
  return (
    <BulkChangeOwnerModal
      key="bulk-change-owner-modal"
      selectAllHostsMode={selectAllHostsMode}
      selectedCount={selectedCount}
      selectedResults={selectedResults}
      fetchBulkParams={fetchBulkParams}
      isOpen={modalOpen}
      closeModal={setModalClosed}
    />
  );
};

export default BulkChangeOwnerModalScene;
