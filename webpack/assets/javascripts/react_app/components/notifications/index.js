import onClickOutside from 'react-onclickoutside';
import React from 'react';
import { connect } from 'react-redux';
import { groupBy } from 'lodash';
import { NotificationDrawerWrapper } from 'patternfly-react';

import * as NotificationActions from '../../redux/actions/notifications';
import './notifications.scss';
import ToggleIcon from './toggleIcon';


class notificationContainer extends React.Component {
  componentDidMount() {
    const { startNotificationsPolling, data: { url } } = this.props;

    startNotificationsPolling(url);
  }

  handleClickOutside() {
    const { isDrawerOpen, isReady, toggleDrawer } = this.props;

    if (isReady && isDrawerOpen) {
      toggleDrawer();
    }
  }

  render() {
    const {
      notifications,
      isDrawerOpen,
      toggleDrawer,
      expandGroup,
      expandedGroup,
      markAsRead,
      markGroupAsRead,
      clearNotification,
      clearGroup,
      hasUnreadMessages,
      isReady,
      clickedLink,
    } = this.props;

    const notificationGroups = Object.entries(notifications).map(([key, group]) => ({
      panelkey: key,
      panelName: key,
      notifications: group,
    }));

    const translations = {
      title: __('Notifications'),
      unreadEvent: __('Unread Event'),
      unreadEvents: __('Unread Events'),
      emptyState: __('No Notifications Available'),
      readAll: __('Mark All Read'),
      clearAll: __('Clear All'),
      deleteNotification: __('Hide this notification'),
    };

    return (
      <div>
        <ToggleIcon hasUnreadMessages={hasUnreadMessages} onClick={toggleDrawer} />
        {isReady &&
          isDrawerOpen && (
            <NotificationDrawerWrapper
              panels={notificationGroups}
              expandedPanel={expandedGroup}
              togglePanel={expandGroup}
              onNotificationAsRead={markAsRead}
              onNotificationHide={clearNotification}
              onMarkPanelAsRead={markGroupAsRead}
              onMarkPanelAsClear={clearGroup}
              onClickedLink={clickedLink}
              toggleDrawerHide={toggleDrawer}
              isExpandable={false}
              translations={translations}
            />
          )}
      </div>
    );
  }
}

const mapStateToProps = (state) => {
  const {
    notifications,
    isDrawerOpen,
    expandedGroup,
    isPolling,
    hasUnreadMessages,
  } = state.notifications;

  return {
    isDrawerOpen,
    isPolling,
    notifications: groupBy(notifications, n => n.group),
    expandedGroup,
    isReady: !!notifications,
    hasUnreadMessages,
  };
};

export default connect(mapStateToProps, NotificationActions)(onClickOutside(notificationContainer));
