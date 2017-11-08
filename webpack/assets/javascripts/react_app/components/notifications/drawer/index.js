import React from 'react';
import NotificationsGroup from './notificationGroup';

export default ({
  notificationGroups,
  expandedGroup,
  toggleDrawer,
  onExpandGroup,
  onMarkAsRead,
  onMarkGroupAsRead,
  onClickedLink,
}) => {
  const groups = Object.keys(notificationGroups).map(key => (
    <NotificationsGroup
      group={key}
      key={key}
      onClickedLink={onClickedLink}
      onMarkAsRead={onMarkAsRead}
      onMarkGroupAsRead={onMarkGroupAsRead}
      isExpanded={expandedGroup === key}
      onExpand={onExpandGroup}
      notifications={notificationGroups[key]}
    />
  ));
  const noNotificationsMessage = (
    <div id="no-notifications-container">{__('No Notifications')}</div>
  );

  return (
    <div className="drawer-pf drawer-pf-notifications-non-clickable">
      <div className="drawer-pf-title">
        <a
          className="drawer-pf-close pficon pficon-close"
          onClick={toggleDrawer}
        />
        <h3 className="text-center">{__('Notifications')}</h3>
      </div>
      <div className="panel-group" id="notification-drawer-accordion">
        {groups.length === 0 ? noNotificationsMessage : groups}
      </div>
    </div>
  );
};
