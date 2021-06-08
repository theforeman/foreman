import React, { Fragment } from 'react';
import PropTypes from 'prop-types';
import {
  CheckCircleIcon,
  ExclamationTriangleIcon,
  ExclamationCircleIcon,
} from '@patternfly/react-icons';

const StatusIcon = ({ status }) => {
  switch (status) {
    case 0:
      return (
        <CheckCircleIcon
          style={{ color: 'var(--pf-global--success-color--100)' }}
        />
      );
    case 1:
      return (
        <ExclamationTriangleIcon
          style={{ color: 'var(--pf-global--warning-color--100)' }}
        />
      );
    case 2:
      return (
        <ExclamationCircleIcon
          style={{ color: 'var(--pf-global--danger-color--100)' }}
        />
      );
    default:
      return <Fragment />;
  }
};

StatusIcon.propTypes = {
  status: PropTypes.number,
};

StatusIcon.defaultProps = {
  status: null,
};

export default StatusIcon;
