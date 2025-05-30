import React, { useContext } from 'react';
import {
  NotificationDrawerHeader,
  Dropdown,
  DropdownList,
  DropdownItem,
  MenuToggle,
  Icon,
} from '@patternfly/react-core';
import { EllipsisVIcon } from '@patternfly/react-icons';
import { translate as __ } from '../../../common/I18n';
import {
  clearGroup,
  markGroupAsRead,
} from '../../../redux/actions/notifications';
import { NotificationsContext } from '../NotificationsContext';

const NotificationHeader = () => {
  const {
    notifications,
    toggleKebab,
    isKebabExpanded,
    countUnreadMessages,
    closeNotificationsDrawer,
    dispatch,
  } = useContext(NotificationsContext);

  const DRAWER_TOGGLE = 'main';

  const markAllRead = () => {
    Object.keys(notifications).forEach(group =>
      dispatch(markGroupAsRead(group))
    );
    toggleKebab(DRAWER_TOGGLE);
  };

  const clearAll = () => {
    Object.keys(notifications).forEach(group => dispatch(clearGroup(group)));
    toggleKebab(DRAWER_TOGGLE);
  };

  return (
    <NotificationDrawerHeader
      count={countUnreadMessages}
      unreadText="unread"
      title={__('Notifications')}
      onClose={() => closeNotificationsDrawer()}
    >
      <Dropdown
        ouiaId="notification-header-dropdown"
        popperProps={{
          position: 'right',
        }}
        isOpen={isKebabExpanded(DRAWER_TOGGLE)}
        toggle={toggleRef => (
          <MenuToggle
            ref={toggleRef}
            isExpanded={isKebabExpanded(DRAWER_TOGGLE)}
            onClick={() => toggleKebab(DRAWER_TOGGLE)}
            variant="plain"
            aria-label="Toggle dropdown"
            ouiaId="notification-header-dropdown-btn"
          >
            <Icon>
              <EllipsisVIcon aria-hidden="true" />
            </Icon>
          </MenuToggle>
        )}
      >
        <DropdownList>
          <DropdownItem
            key="markAllRead"
            ouiaId="markAllRead"
            onClick={markAllRead}
            isDisabled={!countUnreadMessages}
          >
            {__('Mark all read')}
          </DropdownItem>
          <DropdownItem key="clearAll" ouiaId="clearAll" onClick={clearAll}>
            {__('Clear all')}
          </DropdownItem>
        </DropdownList>
      </Dropdown>
    </NotificationDrawerHeader>
  );
};

export default NotificationHeader;
