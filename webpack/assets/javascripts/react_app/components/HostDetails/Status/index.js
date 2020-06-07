import React, { useCallback } from 'react';
import { Alert } from '@patternfly/react-core';

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
        return ['info', ''];
    }
  }, [status]);
  const [variant, title] = statusToLabel();
  return <Alert variant={variant} title={title} />;
};

export default Status;
