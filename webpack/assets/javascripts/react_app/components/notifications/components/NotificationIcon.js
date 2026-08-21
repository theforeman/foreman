import React, { useContext } from 'react';
import { NotificationBadge } from '@patternfly/react-core';
import { translate as __ } from '../../../common/I18n';
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
      aria-label={__('Notifications')}
      variant={variant}
      isExpanded={isExpanded}
      onClick={closeNotificationsDrawer}
      count={countUnreadMessages}
    />
  );
};

export default NotificationIcon;
