import { groupBy, isUndefined } from 'lodash';
import onClickOutside from 'react-onclickoutside';
import { connect } from 'react-redux';
import React from 'react';

import * as NotificationActions from '../../redux/actions/notifications';

import './notifications.scss';
import ToggleIcon from './toggleIcon/';
import Drawer from './drawer/';

class notificationContainer extends React.Component {
  componentDidMount() {
    const { startNotificationsPolling, data: { url } } = this.props;

    startNotificationsPolling(url);
  }

  handleClickOutside() {
    const {
      isDrawerOpen,
      isReady,
      toggleDrawer,
    } = this.props;

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
      onMarkAsRead,
      onMarkGroupAsRead,
      hasUnreadMessages,
      isReady,
      onClickedLink,
    } = this.props;

    return (
      <div id="notifications_container">
        <ToggleIcon
          hasUnreadMessages={hasUnreadMessages}
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
            toggleDrawer={toggleDrawer}
          />}
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
    notifications: groupBy(notifications, 'group'),
    expandedGroup,
    isReady: !isUndefined(notifications),
    hasUnreadMessages,
  };
};

export default connect(mapStateToProps, NotificationActions)(onClickOutside(notificationContainer));
