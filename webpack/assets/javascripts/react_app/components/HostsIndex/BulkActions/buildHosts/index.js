import React, { useContext } from 'react';
import { ForemanActionsBarContext } from '../../../../components/HostDetails/ActionsBar';
import { useForemanModal } from '../../../../components/ForemanModal/ForemanModalHooks';
import { useForemanOrganization } from '../../../../Root/Context/ForemanContext';
import BulkBuildHostModal from './BulkBuildHostModal';

const BulkBuildHostModalScene = () => {
  const { selectedCount, fetchBulkParams } = useContext(
    ForemanActionsBarContext
  );
  const { modalOpen, setModalClosed } = useForemanModal({
    id: 'bulk-build-hosts-modal',
  });
  const org = useForemanOrganization();
  return (
    <BulkBuildHostModal
      key="bulk-build-hosts-modal"
      selectedCount={selectedCount}
      fetchBulkParams={fetchBulkParams}
      isOpen={modalOpen}
      closeModal={setModalClosed}
      orgId={org?.id}
    />
  );
};

export default BulkBuildHostModalScene;
