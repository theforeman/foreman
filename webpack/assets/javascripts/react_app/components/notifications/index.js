import { groupBy, isUndefined } from 'lodash';
import { connect } from 'react-redux';
import React from 'react';

import helpers from '../../common/helpers';
import * as NotificationActions from '../../redux/actions/notifications';

import './notifications.scss';
import ToggleIcon from './toggleIcon/';
import Drawer from './drawer/';

class notificationContainer extends React.Component {
  constructor(props) {
    super(props);

    helpers.bindMethods(this, [
      'attachContainerRef', 'handleToggleClick', 'handleDocumentClick',
    ]);
  }

  componentDidMount() {
    const { startNotificationsPolling, data: { url } } = this.props;

    startNotificationsPolling(url);

    this.updateDocumentClickListenerAfterMount();
  }

  componentWillUnmount() {
    this.unassignDocumentClickHandler();
  }

  assignDocumentClickHandler() {
    document.addEventListener('click', this.handleDocumentClick, true);
  }

  unassignDocumentClickHandler() {
    document.removeEventListener('click', this.handleDocumentClick, true);
  }

  attachContainerRef(ref) {
    this.containerRef = ref;
  }

  handleDocumentClick(e) {
    // handle toggle drawer if clicked outside the drawer
    if (!this.containerRef.contains(e.target)) {
      this.handleToggleClick();
    }
  }

  handleToggleClick() {
    const { isReady, toggleDrawer } = this.props;

    if (isReady) {
      this.updateDocumentClickListenerBeforeToggle();

      toggleDrawer();
    }
  }

  updateDocumentClickListenerAfterMount() {
    if (this.props.isDrawerOpen) {
      this.assignDocumentClickHandler()();
    }
  }

  updateDocumentClickListenerBeforeToggle() {
    if (this.props.isDrawerOpen) {
      this.unassignDocumentClickHandler();
    } else {
      this.assignDocumentClickHandler();
    }
  }

  render() {
    const {
      notifications,
      isDrawerOpen,
      expandGroup,
      expandedGroup,
      onMarkAsRead,
      onMarkGroupAsRead,
      hasUnreadMessages,
      isReady,
      onClickedLink,
    } = this.props;

    return (
      <div id="notifications_container" ref={this.attachContainerRef}>
        <ToggleIcon
          hasUnreadMessages={hasUnreadMessages}
          onClick={this.handleToggleClick}
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
            toggleDrawer={this.handleToggleClick}
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

export default connect(mapStateToProps, NotificationActions)(notificationContainer);
