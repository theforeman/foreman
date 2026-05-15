import PropTypes from 'prop-types';
import React from 'react';
import { translate as __ } from '../../../common/I18n';
import { visit, foremanUrl } from '../../../common/helpers';
import { ResourceLoadFailedEmptyState } from '../../common/EmptyState';
import {
  useForemanHostsPageUrl,
  useForemanSettings,
} from '../../../Root/Context/ForemanContext';

const HostDetailsEmptyState = ({ hostname, httpStatus, errorMessage }) => {
  const { displayNewHostsPage } = useForemanSettings();
  const hostsIndexUrl = useForemanHostsPageUrl();

  const hostsIndexAction = displayNewHostsPage
    ? { url: hostsIndexUrl }
    : { onClick: () => visit(foremanUrl(hostsIndexUrl)) };

  return (
    <ResourceLoadFailedEmptyState
      resourceLabel={__('host')}
      resourceId={hostname}
      httpStatus={httpStatus}
      errorMessage={errorMessage}
      viewPermissions={['view_hosts']}
      primaryAction={{
        label: __('Back to all hosts'),
        ...hostsIndexAction,
        ouiaId: 'host-details-empty-state-all-hosts',
      }}
      requiredPermissions={['view_hosts', 'create_hosts']}
      secondaryActions={[
        {
          label: __('Create a new host'),
          onClick: () => visit(foremanUrl('/hosts/new')),
          ouiaId: 'host-details-empty-state-create-host',
        },
      ]}
      ouiaIdPrefix="host-details-empty-state"
    />
  );
};

HostDetailsEmptyState.propTypes = {
  hostname: PropTypes.string.isRequired,
  httpStatus: PropTypes.number,
  errorMessage: PropTypes.string,
};

HostDetailsEmptyState.defaultProps = {
  httpStatus: null,
  errorMessage: null,
};

export default HostDetailsEmptyState;
