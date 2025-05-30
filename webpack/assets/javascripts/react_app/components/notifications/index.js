import React, { useContext } from 'react';
import { createPortal } from 'react-dom';
import {
  NotificationDrawer,
  NotificationDrawerBody,
  NotificationDrawerList,
  NotificationDrawerGroupList,
  NotificationDrawerGroup,
} from '@patternfly/react-core';

import NotificationHeader from './components/NotificationHeader';
import NotificationItems from './components/NotificationListItems';
import NotificationGroupFooter from './components/NotificationGroupFooter';
import { NotificationsContext } from './NotificationsContext';

import './notifications.scss';

const Notifications = () => {
  const {
    isKebabExpanded,
    drawerRef,
    isExpanded,
    notifications,
    isGroupExpanded,
    toggleKebab,
    toggleNotifications,
  } = useContext(NotificationsContext);

  const unreadPerGroup = groupItems => groupItems.filter(i => !i.seen).length;

  const notificationDrawer = (
    <>
      {isExpanded && (
        <NotificationDrawer ref={drawerRef} className="notifications">
          <NotificationHeader
            toggleKebab={toggleKebab}
            isKebabExpanded={isKebabExpanded}
          />
          <NotificationDrawerBody>
            <NotificationDrawerGroupList>
              {Object.entries(notifications).map(([groupName, items], key) => (
                <NotificationDrawerGroup
                  key={key}
                  title={groupName}
                  id={groupName}
                  count={unreadPerGroup(items) || items.length}
                  isRead={unreadPerGroup(items) === 0}
                  isExpanded={isGroupExpanded(key)}
                  onExpand={() => toggleNotifications(key)}
                >
                  <NotificationDrawerList isHidden={!isGroupExpanded(key)}>
                    <NotificationItems
                      isKebabExpanded={isKebabExpanded}
                      toggleKebab={toggleKebab}
                      items={items}
                    />
                    <NotificationGroupFooter
                      groupName={groupName}
                      unread={unreadPerGroup(items)}
                    />
                  </NotificationDrawerList>
                </NotificationDrawerGroup>
              ))}
            </NotificationDrawerGroupList>
          </NotificationDrawerBody>
        </NotificationDrawer>
      )}
    </>
  );

  return <>{createPortal(notificationDrawer, document.body)}</>;
};

export default Notifications;
