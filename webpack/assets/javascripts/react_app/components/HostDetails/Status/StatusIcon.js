import PropTypes from 'prop-types';
import React from 'react';
import {
  ExclamationTriangleIcon,
  CheckCircleIcon,
  ExclamationCircleIcon,
  BanIcon,
} from '@patternfly/react-icons';
import { Icon } from '@patternfly/react-core';
import './styles.scss';
import {
  ERROR_STATUS_STATE,
  NA_STATUS_STATE,
  OK_STATUS_STATE,
  WARNING_STATUS_STATE,
} from './Constants';
import { ICON_CONTENT_COLOR_VARIABLE } from '../../../constants';

const StatusIcon = ({ statusNumber, label }) => (
  <span className="host-status-icon-container">
    {(() => {
      switch (statusNumber) {
        case OK_STATUS_STATE:
          return (
            <span className="status-success">
              <Icon isInline status="success">
                <CheckCircleIcon />
              </Icon>
              {label}
            </span>
          );
        case WARNING_STATUS_STATE:
          return (
            <span className="status-warning">
              <Icon isInline status="warning">
                <ExclamationTriangleIcon />
              </Icon>
              {label}
            </span>
          );
        case ERROR_STATUS_STATE:
          return (
            <span className="status-error">
              <Icon isInline status="danger">
                <ExclamationCircleIcon />
              </Icon>
              {label}
            </span>
          );
        case NA_STATUS_STATE:
          return (
            <span className="disabled">
              <Icon
                isInline
                style={{
                  [ICON_CONTENT_COLOR_VARIABLE]:
                    'var(--pf-t--global--icon--color--disabled)',
                }}
              >
                <BanIcon />
              </Icon>
              {label}
            </span>
          );
        default:
          return null;
      }
    })()}
  </span>
);

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
