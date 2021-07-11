import React from 'react';
import PropTypes from 'prop-types';
import {
  EmptyState,
  EmptyStateIcon,
  Spinner,
  EmptyStateVariant,
  Title,
} from '@patternfly/react-core';
import { ExclamationCircleIcon } from '@patternfly/react-icons';

import { STATUS } from '../../../../../../constants';
import { translate as __, sprintf } from '../../../../../../common/I18n';

const TableEmptyState = ({ status, error, rowsLength }) => {
  switch (status) {
    case STATUS.RESOLVED:
      return rowsLength === 0 ? (
        <EmptyState variant={EmptyStateVariant.small}>
          <EmptyStateIcon
            variant="container"
            component={ExclamationCircleIcon}
          />
          <Title headingLevel="h2" size="lg">
            {__('No results were found')}
          </Title>
        </EmptyState>
      ) : null;
    case STATUS.PENDING:
      return (
        <EmptyState variant={EmptyStateVariant.small}>
          <EmptyStateIcon variant="container" component={Spinner} />
          <Title headingLevel="h2" size="lg">
            {__('Loading')}
          </Title>
        </EmptyState>
      );
    case STATUS.ERROR:
      return (
        <EmptyState variant={EmptyStateVariant.small}>
          <EmptyStateIcon
            variant="container"
            component={ExclamationCircleIcon}
          />
          <Title headingLevel="h2" size="lg">
            {sprintf(__('The server returned the following error: %s'), error)}
          </Title>
        </EmptyState>
      );
    default:
      return null;
  }
};

TableEmptyState.propTypes = {
  status: PropTypes.string,
  error: PropTypes.string,
  rowsLength: PropTypes.number,
};

TableEmptyState.defaultProps = {
  status: null,
  error: null,
  rowsLength: null,
};

export default TableEmptyState;
