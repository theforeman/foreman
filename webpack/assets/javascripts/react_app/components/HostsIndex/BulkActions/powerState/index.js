import React, { useContext } from 'react';
import PropTypes from 'prop-types';
import { ForemanActionsBarContext } from '../../../../components/HostDetails/ActionsBar';
import BulkPowerStateModal from './BulkPowerStateModal';

const BulkPowerStateModalScene = ({ isOpen, closeModal }) => {
  const {
    fetchBulkParams,
    selectedCount = 0,
    organizationId,
    locationId,
  } = useContext(ForemanActionsBarContext);
  return (
    <BulkPowerStateModal
      selectedHostsCount={selectedCount}
      fetchBulkParams={fetchBulkParams}
      organizationId={organizationId}
      locationId={locationId}
      isOpen={isOpen}
      closeModal={closeModal}
    />
  );
};

export default BulkPowerStateModalScene;

BulkPowerStateModalScene.propTypes = {
  isOpen: PropTypes.bool.isRequired,
  closeModal: PropTypes.func.isRequired,
};
