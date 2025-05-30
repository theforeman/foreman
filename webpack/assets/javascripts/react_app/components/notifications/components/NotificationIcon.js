import React, { useContext } from 'react';
import { NotificationBadge } from '@patternfly/react-core';
import { NotificationsContext } from '../NotificationsContext';

const NotificationIcon = () => {
  const {
    isExpanded,
    closeNotificationsDrawer,
    variant,
    countUnreadMessages,
  } = useContext(NotificationsContext);

  return (
    <NotificationBadge
      id="notification-badge"
      variant={variant}
      isExpanded={isExpanded}
      onClick={closeNotificationsDrawer}
      count={countUnreadMessages}
    />
  );
};

export default NotificationIcon;
