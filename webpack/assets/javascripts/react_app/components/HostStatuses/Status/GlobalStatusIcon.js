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
            color: 'var(--pf-t--global--icon--color--status--success--default)',
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
            color: 'var(--pf-t--global--icon--color--status--warning--default)',
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
            color: 'var(--pf-t--global--icon--color--status--danger--default)',
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
            color: 'var(--pf-t--global--icon--color--status--info--default)',
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
