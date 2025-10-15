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

const GlobalStatusIcon = ({ status, style, ...props }) => {
  switch (status) {
    case GLOBAL_STATUS_OK:
      return (
        <CheckCircleIcon
          style={{ fill: 'var(--pf-v5-global--success-color--100)', ...style }}
          {...props}
        />
      );
    case GLOBAL_STATUS_WARN:
      return (
        <ExclamationTriangleIcon
          style={{ fill: 'var(--pf-v5-global--warning-color--100)', ...style }}
          {...props}
        />
      );
    case GLOBAL_STATUS_ERROR:
      return (
        <ExclamationCircleIcon
          style={{ fill: 'var(--pf-v5-global--danger-color--100)', ...style }}
          {...props}
        />
      );
    default:
      return (
        <QuestionCircleIcon
          style={{ fill: 'var(--pf-v5-global--info-color--200)', ...style }}
          {...props}
        />
      );
  }
};

GlobalStatusIcon.propTypes = {
  status: PropTypes.number,
  style: PropTypes.object,
};

GlobalStatusIcon.defaultProps = {
  status: undefined,
  style: undefined,
};

export default GlobalStatusIcon;
