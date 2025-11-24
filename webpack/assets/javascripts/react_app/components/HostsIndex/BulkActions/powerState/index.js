import React, { useContext } from 'react';
import { ForemanActionsBarContext } from '../../../../components/HostDetails/ActionsBar';
import { useForemanModal } from '../../../../components/ForemanModal/ForemanModalHooks';
import BulkPowerStateModal from './BulkPowerStateModal';

const BulkPowerStateModalScene = () => {
  const { fetchBulkParams, selectedCount = 0 } = useContext(
    ForemanActionsBarContext
  );
  const { modalOpen, setModalClosed } = useForemanModal({
    id: 'bulk-power-state-modal',
  });

  return (
    <BulkPowerStateModal
      selectedHostsCount={selectedCount}
      fetchBulkParams={fetchBulkParams}
      isOpen={modalOpen}
      closeModal={setModalClosed}
    />
  );
};

export default BulkPowerStateModalScene;
