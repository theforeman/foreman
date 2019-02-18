import React from '@theforeman/vendor/react';
import { OverlayTrigger, Tooltip } from '@theforeman/vendor/react-bootstrap';
import PropTypes from '@theforeman/vendor/prop-types';
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
