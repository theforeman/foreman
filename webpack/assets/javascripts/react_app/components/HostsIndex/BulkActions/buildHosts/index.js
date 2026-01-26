import React, { useContext } from 'react';
import PropTypes from 'prop-types';
import { ForemanActionsBarContext } from '../../../../components/HostDetails/ActionsBar';
import BulkBuildHostModal from './BulkBuildHostModal';

const BulkBuildHostModalScene = ({ isOpen, closeModal }) => {
  const { selectedCount, fetchBulkParams } = useContext(
    ForemanActionsBarContext
  );
  return (
    <BulkBuildHostModal
      key="bulk-build-hosts-modal"
      selectedCount={selectedCount}
      fetchBulkParams={fetchBulkParams}
      isOpen={isOpen}
      closeModal={closeModal}
    />
  );
};

export default BulkBuildHostModalScene;

BulkBuildHostModalScene.propTypes = {
  isOpen: PropTypes.bool.isRequired,
  closeModal: PropTypes.func.isRequired,
};
