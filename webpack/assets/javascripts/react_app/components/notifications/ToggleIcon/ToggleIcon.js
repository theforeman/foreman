import React from 'react';
import { Tooltip, TooltipPosition } from '@patternfly/react-core';
import PropTypes from 'prop-types';
import { noop } from '../../../common/helpers';
import { translate as __ } from '../../../common/I18n';

const ToggleIcon = ({ hasUnreadMessages, onClick }) => {
  const iconType = hasUnreadMessages ? 'fa-bell' : 'fa-bell-o';
  return (
    <Tooltip
      position={TooltipPosition.bottom}
      id="notifications-toggle-icon"
      content={__('Notifications')}
    >
      <span
        onClick={onClick}
        className={`fa ${iconType}`}
        aria-describedby="tooltip"
      />
    </Tooltip>
  );
};

ToggleIcon.propTypes = {
  hasUnreadMessages: PropTypes.bool,
  onClick: PropTypes.func,
};

ToggleIcon.defaultProps = {
  hasUnreadMessages: false,
  onClick: noop,
};

export default ToggleIcon;
