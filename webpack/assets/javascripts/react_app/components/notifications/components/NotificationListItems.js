import React from 'react';
import PropTypes from 'prop-types';
import { useDispatch } from 'react-redux';
import { EllipsisVIcon } from '@patternfly/react-icons/dist/js/icons/ellipsis-v-icon';
import {
  NotificationDrawerListItem,
  NotificationDrawerListItemBody,
  NotificationDrawerListItemHeader,
  Dropdown,
  DropdownList,
  DropdownItem,
  MenuToggle,
  Divider,
  Icon,
} from '@patternfly/react-core';
import { translate as __ } from '../../../common/I18n';
import {
  markAsRead,
  clearNotification,
} from '../../../redux/actions/notifications';
import { formatDateTime } from '../NotificationsDrawerHelpers';

const NotificationItems = ({ isKebabExpanded, toggleKebab, items }) => {
  const dispatch = useDispatch();

  const parseActions = notification => (
    <DropdownList>
      {notification.actions.links &&
        notification.actions.links.length > 0 &&
        notification.actions.links.map((action, index) => (
          <DropdownItem
            key={action.href}
            ouiaId={`dropdown-item-${action.title}-${index}`}
            to={action.href}
          >
            {__(action.title)}
          </DropdownItem>
        ))}
      <Divider component="li" key="separator" />
      <DropdownItem
        key={`static-${notification.id}`}
        ouiaId={`dropdown-item-static-${notification.id}`}
        onClick={() => dispatch(clearNotification(notification.id))}
      >
        {__('Hide this notification')}
      </DropdownItem>
    </DropdownList>
  );

  const generateListItemHeader = notification => (
    <NotificationDrawerListItemHeader
      title={notification.text}
      headingLevel="h4"
    >
      <Dropdown
        popperProps={{
          position: 'right',
        }}
        className="popper-position"
        onSelect={() => toggleKebab(notification.id)}
        isOpen={isKebabExpanded(notification.id)}
        ouiaId={`kebab-${notification}`}
        toggle={toggleRef => (
          <MenuToggle
            ref={toggleRef}
            id="toggle-id-0"
            ouiaId={`menuToggle-${notification.id}`}
            aria-label="Notification drawer actions"
            variant="plain"
            onClick={() => toggleKebab(notification.id)}
            isExpanded={isKebabExpanded(notification.id)}
          >
            <Icon>
              <EllipsisVIcon aria-hidden="true" />
            </Icon>
          </MenuToggle>
        )}
      >
        {parseActions(notification)}
      </Dropdown>
    </NotificationDrawerListItemHeader>
  );

  return (
    <>
      {items.map((notification, index) => (
        <NotificationDrawerListItem
          variant={
            notification.level === 'error' ? 'danger' : notification.level
          }
          key={index}
          isRead={notification.seen}
          onClick={() => {
            if (!notification.seen) dispatch(markAsRead(notification.id));
          }}
        >
          {generateListItemHeader(notification)}
          <NotificationDrawerListItemBody
            timestamp={formatDateTime(notification.created_at)}
          />
        </NotificationDrawerListItem>
      ))}
    </>
  );
};

NotificationItems.propTypes = {
  items: PropTypes.array.isRequired,
  isKebabExpanded: PropTypes.func.isRequired,
  toggleKebab: PropTypes.func.isRequired,
};

export default NotificationItems;
