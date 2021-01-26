import PropTypes from 'prop-types';
import React from 'react';
import {
  ExclamationTriangleIcon,
  CheckCircleIcon,
  ExclamationCircleIcon,
  BanIcon,
} from '@patternfly/react-icons';
import './styles.scss';
import {
  ERROR_STATUS_STATE,
  NA_STATUS_STATE,
  OK_STATUS_STATE,
  WARNING_STATUS_STATE,
} from './Constants';

const StatusIcon = ({ statusNumber, label }) => {
  switch (statusNumber) {
    case OK_STATUS_STATE:
      return (
        <span className="status-success">
          <CheckCircleIcon /> {label}
        </span>
      );
    case WARNING_STATUS_STATE:
      return (
        <span className="status-warning">
          <ExclamationTriangleIcon /> {label}
        </span>
      );

    case ERROR_STATUS_STATE:
      return (
        <span className="status-error">
          <ExclamationCircleIcon /> {label}
        </span>
      );
    case NA_STATUS_STATE:
      return (
        <span className="disabled">
          <BanIcon /> {label}
        </span>
      );
    default:
      return null;
  }
};

StatusIcon.propTypes = {
  label: PropTypes.string,
  statusNumber: PropTypes.number,
};

StatusIcon.defaultProps = {
  label: '',
  statusNumber: undefined,
};

export default StatusIcon;
