import React from 'react';
import PropTypes from 'prop-types';
import { Icon } from '@patternfly/react-core';
import {
  ExclamationCircleIcon,
  ExclamationTriangleIcon,
  CheckCircleIcon,
} from '@patternfly/react-icons';

export const FailIcon = props => (
  <Icon status="danger" {...props}>
    <ExclamationCircleIcon />
  </Icon>
);

export const WarnIcon = props => (
  <Icon status="warning" {...props}>
    <ExclamationTriangleIcon />
  </Icon>
);

export const OKIcon = props => (
  <Icon status="success" {...props}>
    <CheckCircleIcon />
  </Icon>
);

export const StatusValue = ({ val }) => {
  if (['OK', 'Ok', 'true', 'ok'].includes(val)) {
    return (
      <span className="bss-status-value">
        <OKIcon />
        {val}
      </span>
    );
  }
  if (['FAIL', 'fail', 'false'].includes(val)) {
    return (
      <span className="bss-status-value">
        <FailIcon />
        {val}
      </span>
    );
  }
  return val;
};

StatusValue.propTypes = {
  val: PropTypes.oneOfType([PropTypes.string, PropTypes.shape({})]),
};

StatusValue.defaultProps = {
  val: '',
};
