import PropTypes from 'prop-types';
import React from 'react';
import { EmptyState, EmptyStateVariant } from '@patternfly/react-core';
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
      <EmptyState
        variant={EmptyStateVariant.xs}
        headingLevel="h4"
        icon={showBanIcon ? BanIcon : CheckCircleIcon}
        status={showBanIcon ? undefined : 'success'}
        titleText={
          <>{cannotViewStatuses ? __('No statuses to show') : statusText}</>
        }
        style={{ marginTop: '-1px' }}
        isFullHeight
      />
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
