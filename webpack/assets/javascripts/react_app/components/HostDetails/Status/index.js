import PropTypes from 'prop-types';
import React, { useCallback } from 'react';
import { Alert } from '@patternfly/react-core';
import Skeleton from 'react-loading-skeleton';

const Status = ({ status }) => {
  const statusToLabel = useCallback(() => {
    switch (status) {
      case 'OK':
        return ['success', 'Host Status - OK'];
      case 'Error':
        return ['danger', 'Host Status - ERROR'];
      case 'Warning':
        return ['warning', 'Host Status - WARNING '];
      default:
        return ['info', null];
    }
  }, [status]);
  const [variant, title] = statusToLabel();
  return <Alert variant={variant} title={title || <Skeleton />} />;
};

Status.propTypes = {
  status: PropTypes.string.isRequired,
};

export default Status;
