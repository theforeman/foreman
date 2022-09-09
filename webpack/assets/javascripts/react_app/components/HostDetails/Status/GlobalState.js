import PropTypes from 'prop-types';
import React from 'react';
import { Title, EmptyState, EmptyStateIcon } from '@patternfly/react-core';
import { global_success_color_100 as successColor } from '@patternfly/react-tokens';
import { CheckCircleIcon, BanIcon } from '@patternfly/react-icons';
import { translate as __ } from '../../../common/I18n';
import { STATUS } from '../../../constants';

const GlobalState = ({
  responseStatus,
  isOKState,
  cannotViewStatuses,
  allStatusesCleared,
  children,
}) => {
  if (responseStatus === STATUS.RESOLVED && (isOKState || cannotViewStatuses)) {
    const showBanIcon = cannotViewStatuses || allStatusesCleared;
    const statusText = allStatusesCleared
      ? __('All statuses cleared')
      : __('All statuses OK');
    return (
      <EmptyState style={{ marginTop: '-1px' }} isFullHeight>
        <EmptyStateIcon
          icon={showBanIcon ? BanIcon : CheckCircleIcon}
          color={showBanIcon ? undefined : successColor.value}
        />
        <Title ouiaId="global-state-title" size="lg" headingLevel="h4">
          {cannotViewStatuses ? __('No statuses to show') : statusText}
        </Title>
      </EmptyState>
    );
  }

  return children;
};

GlobalState.propTypes = {
  cannotViewStatuses: PropTypes.bool.isRequired,
  children: PropTypes.node.isRequired,
  isOKState: PropTypes.bool.isRequired,
  allStatusesCleared: PropTypes.bool.isRequired,
  responseStatus: PropTypes.string,
};

GlobalState.defaultProps = {
  responseStatus: STATUS.PENDING,
};

export default GlobalState;
