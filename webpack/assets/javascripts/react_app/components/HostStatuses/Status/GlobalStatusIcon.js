import React from 'react';
import PropTypes from 'prop-types';
import {
  CheckCircleIcon,
  ExclamationTriangleIcon,
  ExclamationCircleIcon,
  QuestionCircleIcon,
} from '@patternfly/react-icons';
import { Icon } from '@patternfly/react-core';
import {
  GLOBAL_STATUS_OK,
  GLOBAL_STATUS_WARN,
  GLOBAL_STATUS_ERROR,
} from '../HostStatusesConstants';

const GlobalStatusIcon = ({ status, style, ...props }) => {
  switch (status) {
    case GLOBAL_STATUS_OK:
      return (
        <Icon
          style={{
            color: 'var(--pf-v5-global--success-color--100)',
            ...style,
          }}
          {...props}
        >
          <CheckCircleIcon />
        </Icon>
      );
    case GLOBAL_STATUS_WARN:
      return (
        <Icon
          style={{
            color: 'var(--pf-v5-global--warning-color--100)',
            ...style,
          }}
          {...props}
        >
          <ExclamationTriangleIcon />
        </Icon>
      );
    case GLOBAL_STATUS_ERROR:
      return (
        <Icon
          style={{
            color: 'var(--pf-v5-global--danger-color--100)',
            ...style,
          }}
          {...props}
        >
          <ExclamationCircleIcon />
        </Icon>
      );
    default:
      return (
        <Icon
          style={{
            color: 'var(--pf-v5-global--info-color--200)',
            ...style,
          }}
          {...props}
        >
          <QuestionCircleIcon />
        </Icon>
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
