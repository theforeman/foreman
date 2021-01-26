import PropTypes from 'prop-types';
import React from 'react';
import { Title, EmptyState, EmptyStateIcon } from '@patternfly/react-core';
import { OkIcon, BanIcon } from '@patternfly/react-icons';
import { translate as __ } from '../../../common/I18n';
import { STATUS } from '../../../constants';

const GlobalState = ({
  responseStatus,
  isOKState,
  cannotViewStatuses,
  children,
}) => {
  if (responseStatus === STATUS.RESOLVED && (isOKState || cannotViewStatuses))
    return (
      <EmptyState style={{ marginTop: '-1px' }} isFullHeight>
        <EmptyStateIcon icon={cannotViewStatuses ? BanIcon : OkIcon} />
        <Title size="lg" headingLevel="h4">
          {cannotViewStatuses
            ? __('No statuses to show')
            : __('All Statuses are OK')}
        </Title>
      </EmptyState>
    );

  return children;
};

GlobalState.propTypes = {
  cannotViewStatuses: PropTypes.bool.isRequired,
  children: PropTypes.node.isRequired,
  isOKState: PropTypes.bool.isRequired,
  responseStatus: PropTypes.string,
};

GlobalState.defaultProps = {
  responseStatus: STATUS.PENDING,
};

export default GlobalState;
