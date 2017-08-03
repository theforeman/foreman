import React from 'react';
import { connect } from 'react-redux';
import * as NotificationActions from '../../redux/actions/notifications';
import './notifications.scss';
import ToggleIcon from './toggleIcon/';
import Drawer from './drawer/';
import { groupBy, isUndefined } from 'lodash';

class notificationContainer extends React.Component {
  componentDidMount() {
    const { startNotificationsPolling, data: { url } } = this.props;

    startNotificationsPolling(url);
  }

  render() {
    const {
      notifications,
      isDrawerOpen,
      toggleDrawer,
      expandGroup,
      expandedGroup,
      onMarkAsRead,
      onMarkGroupAsRead,
      hasUnreadMessages,
      isReady,
      onClickedLink
    } = this.props;

    return (
      <div id="notifications_container">
        <ToggleIcon
          hsUnreadMessages={hasUnreadMessages}
          onClick={toggleDrawer}
        />
        {isReady &&
          isDrawerOpen &&
          <Drawer
            onExpandGroup={expandGroup}
            onClickedLink={onClickedLink}
            onMarkAsRead={onMarkAsRead}
            onMarkGroupAsRead={onMarkGroupAsRead}
            expandedGroup={expandedGroup}
            notificationGroups={notifications}
          />}
      </div>
    );
  }
}

const mapStateToProps = state => {
  const {
    notifications,
    isDrawerOpen,
    expandedGroup,
    isPolling,
    hasUnreadMessages
  } = state.notifications;

  return {
    isDrawerOpen,
    isPolling,
    notifications: groupBy(notifications, 'group'),
    expandedGroup,
    isReady: !isUndefined(notifications),
    hasUnreadMessages
  };
};

export default connect(mapStateToProps, NotificationActions)(
  notificationContainer
);
