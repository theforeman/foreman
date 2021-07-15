import PropTypes from 'prop-types';
import React from 'react';
import {
  ExclamationTriangleIcon,
  CheckCircleIcon,
  ExclamationCircleIcon,
  BanIcon,
} from '@patternfly/react-icons';
import Skeleton from 'react-loading-skeleton';
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
      return <Skeleton width={20} />;
  }
};

StatusIcon.propTypes = {
  label: PropTypes.string,
  statusNumber: PropTypes.number.isRequired,
};

StatusIcon.defaultProps = {
  label: '',
};

export default StatusIcon;
