import React, { useContext } from 'react';
import PropTypes from 'prop-types';
import { ForemanActionsBarContext } from '../../../../components/HostDetails/ActionsBar';
import BulkManageNotificationsModal from './BulkManageNotificationsModal';

const BulkManageNotificationsModalScene = ({
  isOpen,
  closeModal,
  onSuccess,
}) => {
  const { fetchBulkParams, selectedCount = 0 } = useContext(
    ForemanActionsBarContext
  );
  return (
    <BulkManageNotificationsModal
      selectedCount={selectedCount}
      fetchBulkParams={fetchBulkParams}
      isOpen={isOpen}
      closeModal={closeModal}
      onSuccess={onSuccess}
    />
  );
};

export default BulkManageNotificationsModalScene;

BulkManageNotificationsModalScene.propTypes = {
  isOpen: PropTypes.bool.isRequired,
  closeModal: PropTypes.func.isRequired,
  onSuccess: PropTypes.func,
};

BulkManageNotificationsModalScene.defaultProps = {
  onSuccess: undefined,
};
