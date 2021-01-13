import React from 'react';
import Skeleton from 'react-loading-skeleton';
import { Tooltip } from '@patternfly/react-core';
import {
  WarningTriangleIcon,
  OkIcon,
  ErrorCircleOIcon,
  QuestionCircleIcon,
} from '@patternfly/react-icons';

const StatusItem = ({ status, label, name, isReady }) => {
  const StatusIcon = ({ statusNumber }) => {
    switch (statusNumber) {
      case 0:
        return <OkIcon color="#3E8635" />;
      case 1:
        return <WarningTriangleIcon color="#F0AB00" />;
      case 2:
        return <ErrorCircleOIcon color="#C9190B" />;
      default:
        return <QuestionCircleIcon color="#2B9AF3" />;
    }
  };
  return (
    <span className="card-pf-aggregate-status-notification">
      {!isReady ? (
        <Skeleton width={30} />
      ) : (
        <Tooltip content={label || 'N/A'} entryDelay={0} exitDelay={0}>
          <a className="aggregate-text" href="#">
            <StatusIcon statusNumber={status} />{' '}
            {`${name}${status === undefined ? ': N/A' : ''}`}{' '}
          </a>
        </Tooltip>
      )}
    </span>
  );
};

export default StatusItem;
