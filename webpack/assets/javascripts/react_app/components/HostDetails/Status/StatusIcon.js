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

const StatusIcon = ({ statusNumber, label, style }) => {
  switch (statusNumber) {
    case OK_STATUS_STATE:
      return (
        <span className="status-success" style={style}>
          <CheckCircleIcon noVerticalAlign /> {label}
        </span>
      );
    case WARNING_STATUS_STATE:
      return (
        <span className="status-warning" style={style}>
          <ExclamationTriangleIcon noVerticalAlign /> {label}
        </span>
      );

    case ERROR_STATUS_STATE:
      return (
        <span className="status-error" style={style}>
          <ExclamationCircleIcon noVerticalAlign /> {label}
        </span>
      );
    case NA_STATUS_STATE:
      return (
        <span className="disabled" style={style}>
          <BanIcon noVerticalAlign /> {label}
        </span>
      );
    default:
      return null;
  }
};

StatusIcon.propTypes = {
  label: PropTypes.string,
  statusNumber: PropTypes.number,
  style: PropTypes.shape({}),
};

StatusIcon.defaultProps = {
  label: '',
  statusNumber: undefined,
  style: undefined,
};

export default StatusIcon;
