import React from 'react';
import Notification from './Notification';
import './Notifications.css';

const NotificationPanelBody = ({notifications, expandedGroup, group}) => {
  let data;
  let css = expandedGroup === group ? 'panel-body notification-panel-scroll' : 'hide';

  if (notifications && notifications.length) {
    data = notifications
      .map(notification => <Notification key={notification.id} {...notification}></Notification>
      );
  } else {
    data = null;
  }

  return (
    <div className={css}>
    {data}
    </div>
  );
};

export default NotificationPanelBody;
