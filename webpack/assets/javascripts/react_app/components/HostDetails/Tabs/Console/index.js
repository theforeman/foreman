import PropTypes from 'prop-types';
import React from 'react';
import { API_OPERATIONS } from '../../../../redux/API';
import SkeletonLoader from '../../../common/SkeletonLoader';
import { useDangerouslyLegacy } from '../../Console/LegacyLoaderHook';

const ConsoleTab = ({ response: { id: hostID }, isActive }) => {
  const url = hostID && isActive && `/hosts/${hostID}/console`;

  const { status, html } = useDangerouslyLegacy(API_OPERATIONS.GET, url, {
    chosenElement: 'content',
    elementsToRemove: ['breadcrumb', 'back-to-host-btn'],
  });
  return (
    <div className="host-details-tab-item details-tab">
      <SkeletonLoader status={status}>
        <div dangerouslySetInnerHTML={{ __html: html }} />
      </SkeletonLoader>
    </div>
  );
};

ConsoleTab.propTypes = {
  response: PropTypes.object,
  isActive: PropTypes.bool,
};

ConsoleTab.defaultProps = {
  response: undefined,
  isActive: false,
};

export default ConsoleTab;
