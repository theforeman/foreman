import { OverlayTrigger, Tooltip } from 'react-bootstrap';
import React from 'react';

import Icon from '../../common/Icon';
import '../../../common/commonStyles.css';

import NotificationDropdown from './NotificationDropdown';

/* eslint-disable camelcase */

const Notification = ({
  notification: {
    created_at,
    seen,
    text,
    level,
    id,
    actions,
  },
  onMarkAsRead,
  onClickedLink,
}) => {
  const created = new Date(created_at);
  const title = __('Click to mark as read');
  const tooltip = (
    <Tooltip id="tooltip">{ title }</Tooltip>
  );
  const messageText = seen ?
    <span className="drawer-pf-notification-message">{text}</span> :
    (<span
      className="drawer-pf-notification-message not-seen"
      onClick={onMarkAsRead.bind(this, id)}
    >
      <OverlayTrigger placement="top" overlay={tooltip}>
        <span>{ text }</span>
      </OverlayTrigger>
     </span>);

  return (
    <div className="drawer-pf-notification">
      <Icon type={level} />
      <div className="notification-text-container">
        {messageText}
        <div className="drawer-pf-notification-info">
          <span className="date">{created.toLocaleDateString()}</span>
          <span className="time">{created.toLocaleTimeString()}</span>
        </div>
      </div>
      {
        actions.links &&
        <NotificationDropdown
          links={actions.links}
          id={id}
          onClickedLink={onClickedLink}
        />
      }
    </div>
  );
};

export default Notification;
