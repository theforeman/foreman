import PropTypes from 'prop-types';
import React from 'react';
import { PowerOffIcon } from '@patternfly/react-icons';
import { Spinner, Icon } from '@patternfly/react-core';
import { STATUS, ICON_CONTENT_COLOR_VARIABLE } from '../../../../constants';

const POWER_ICON_STATUS = { on: 'success', off: 'danger' };
const UNKNOWN_POWER_STYLE = {
  [ICON_CONTENT_COLOR_VARIABLE]: 'var(--pf-t--global--icon--color--disabled)',
};

const PowerStatusIcon = ({ state, responseStatus }) => {
  if (responseStatus === STATUS.PENDING) return <Spinner size="md" />;
  return (
    <span className={`power-${state}`}>
      <Icon
        id="power-status-icon"
        className={`power-${state}`}
        status={POWER_ICON_STATUS[state]}
        style={POWER_ICON_STATUS[state] ? undefined : UNKNOWN_POWER_STYLE}
      >
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
