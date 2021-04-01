import React from 'react';
import PropTypes from 'prop-types';
import {
  CheckCircleIcon,
  ExclamationTriangleIcon,
  ExclamationCircleIcon,
  QuestionCircleIcon,
} from '@patternfly/react-icons';
import {
  GLOBAL_STATUS_OK,
  GLOBAL_STATUS_WARN,
  GLOBAL_STATUS_ERROR,
} from '../HostStatusesConstants';

const GlobalStatusIcon = ({ status, ...props }) => {
  switch (status) {
    case GLOBAL_STATUS_OK:
      return (
        <CheckCircleIcon
          style={{ fill: 'var(--pf-global--success-color--100)' }}
          {...props}
        />
      );
    case GLOBAL_STATUS_WARN:
      return (
        <ExclamationTriangleIcon
          style={{ fill: 'var(--pf-global--warning-color--100)' }}
          {...props}
        />
      );
    case GLOBAL_STATUS_ERROR:
      return (
        <ExclamationCircleIcon
          style={{ fill: 'var(--pf-global--danger-color--100)' }}
          {...props}
        />
      );
    default:
      return (
        <QuestionCircleIcon
          style={{ fill: 'var(--pf-global--info-color--200)' }}
          {...props}
        />
      );
  }
};

GlobalStatusIcon.propTypes = {
  status: PropTypes.number,
};

GlobalStatusIcon.defaultProps = {
  status: undefined,
};

export default GlobalStatusIcon;
