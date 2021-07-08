import PropTypes from 'prop-types';
import React from 'react';
import { Text, Bullseye } from '@patternfly/react-core';

import { foremanUrl } from '../../../../common/helpers';
import { API_OPERATIONS } from '../../../../redux/API';
import SkeletonLoader from '../../../common/SkeletonLoader';
import { useDangerouslyLegacy } from '../../Console/LegacyLoaderHook';
import { translate as __ } from '../../../../common/I18n';

const ConsoleTab = ({ hostName }) => {
  const url = hostName && foremanUrl(`/hosts/${hostName}/console`);
  const emptyState = (
    <Bullseye>
      <Text style={{ marginTop: '20px' }} component="p">
        {__('No console support')}
      </Text>
    </Bullseye>
  );
  const { status, html } = useDangerouslyLegacy(API_OPERATIONS.GET, url, {
    chosenElement: 'content',
    elementsToRemove: ['breadcrumb', 'back-to-host-btn'],
  });
  return (
    <div className="host-details-tab-item details-tab">
      <SkeletonLoader
        emptyState={emptyState}
        status={status}
        skeletonProps={{ count: 10 }}
      >
        {html && <div dangerouslySetInnerHTML={{ __html: html }} />}
      </SkeletonLoader>
    </div>
  );
};

ConsoleTab.propTypes = {
  hostName: PropTypes.string,
};
ConsoleTab.defaultProps = {
  hostName: '',
};

export default ConsoleTab;
