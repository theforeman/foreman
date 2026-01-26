import React, { useContext } from 'react';
import PropTypes from 'prop-types';
import { ForemanActionsBarContext } from '../../../../components/HostDetails/ActionsBar';
import BulkReassignHostgroupModal from './BulkReassignHostgroupModal';

const BulkReassignHostgroupModalScene = ({ isOpen, closeModal }) => {
  const { selectedCount, fetchBulkParams } = useContext(
    ForemanActionsBarContext
  );
  return (
    <BulkReassignHostgroupModal
      key="bulk-reassign-hg-modal"
      selectedCount={selectedCount}
      fetchBulkParams={fetchBulkParams}
      isOpen={isOpen}
      closeModal={closeModal}
    />
  );
};

export default BulkReassignHostgroupModalScene;

BulkReassignHostgroupModalScene.propTypes = {
  isOpen: PropTypes.bool.isRequired,
  closeModal: PropTypes.func.isRequired,
};
