import React from 'react';
import { OverlayTrigger, Tooltip } from 'patternfly-react';
import PropTypes from 'prop-types';
import { noop } from '../../../common/helpers';

const ToggleIcon = ({ hasUnreadMessages, onClick }) => {
  const iconType = hasUnreadMessages ? 'fa-bell' : 'fa-bell-o';
  const tooltip = <Tooltip id="tooltip">Notifications</Tooltip>;

  return (
    <OverlayTrigger
      placement="bottom"
      id="notifications-toggle-icon"
      overlay={tooltip}
    >
      <span
        onClick={onClick}
        className={`fa ${iconType}`}
        aria-describedby="tooltip"
      />
    </OverlayTrigger>
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
