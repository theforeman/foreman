import PropTypes from 'prop-types';
import React from 'react';
import { PowerOffIcon } from '@patternfly/react-icons';
import { Spinner, Icon } from '@patternfly/react-core';
import { STATUS } from '../../../../constants';

const PowerStatusIcon = ({ state, responseStatus }) => {
  if (responseStatus === STATUS.PENDING) return <Spinner size="md" />;
  return (
    <span className={`power-${state}`}>
      <Icon id="power-status-icon" className={`power-${state}`}>
        <PowerOffIcon />
      </Icon>
    </span>
  );
};

PowerStatusIcon.propTypes = {
  responseStatus: PropTypes.string,
  state: PropTypes.string,
};

PowerStatusIcon.defaultProps = {
  state: 'na',
  responseStatus: STATUS.PENDING,
};

export default PowerStatusIcon;
