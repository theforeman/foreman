import PropTypes from 'prop-types';
import React from 'react';
import { Modal, ModalVariant } from '@patternfly/react-core';
import { STATUS } from '../../../constants';
import SkeletonLoader from '../../common/SkeletonLoader';
import { useDangerouslyLegacy } from './LegacyLoaderHook';
import { foremanUrl, noop } from '../../../common/helpers';
import { API_OPERATIONS } from '../../../redux/API';

const ConsoleModal = ({ onClose, isOpen, hostID }) => {
  const url = hostID && foremanUrl(`/hosts/${hostID}/console`);

  const { status, html } = useDangerouslyLegacy(API_OPERATIONS.GET, url, {
    chosenElement: 'content',
    elementsToRemove: ['breadcrumb', 'back-to-host-btn'],
  });
  return (
    <Modal
      variant={ModalVariant.medium}
      isOpen={isOpen}
      aria-label="No header example"
      showClose
      onClose={onClose}
    >
      <SkeletonLoader status={status} skeletonProps={{ count: 6 }}>
        {status === STATUS.RESOLVED && (
          <div dangerouslySetInnerHTML={{ __html: html }} />
        )}
      </SkeletonLoader>
    </Modal>
  );
};

ConsoleModal.propTypes = {
  hostID: PropTypes.string,
  isOpen: PropTypes.bool,
  onClose: PropTypes.func,
};

ConsoleModal.defaultProps = {
  hostID: undefined,
  isOpen: false,
  onClose: noop,
};

export default ConsoleModal;
