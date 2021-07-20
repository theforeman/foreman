import PropTypes from 'prop-types';
import React from 'react';
import { PowerOffIcon } from '@patternfly/react-icons';
import { Tooltip, Spinner } from '@patternfly/react-core';
import { STATUS } from '../../../constants';
import './styles.scss';

const PowerStatusIcon = ({ state, statusText, title, responseStatus }) => {
  if (responseStatus === STATUS.PENDING) return <Spinner size="md" />;
  return (
    <Tooltip content={statusText}>
      <span className={`power-${state}`}>
        <PowerOffIcon />
      </span>
    </Tooltip>
  );
};

PowerStatusIcon.propTypes = {
  responseStatus: PropTypes.string,
  state: PropTypes.string,
  statusText: PropTypes.string,
  title: PropTypes.string,
};

PowerStatusIcon.defaultProps = {
  title: 'N/A',
  statusText: undefined,
  state: 'na',
  responseStatus: STATUS.PENDING,
};

export default PowerStatusIcon;
