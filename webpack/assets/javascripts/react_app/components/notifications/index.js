import onClickOutside from 'react-onclickoutside';
import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { groupBy } from 'lodash';
import { NotificationDrawerWrapper } from 'patternfly-react';
import { translate as __ } from '../../../react_app/common/I18n';
import * as NotificationActions from '../../redux/actions/notifications';
import { noop } from '../../common/helpers';

import './notifications.scss';
import ToggleIcon from './ToggleIcon/ToggleIcon';

class notificationContainer extends React.Component {
  componentDidMount() {
    const {
      startNotificationsPolling,
      data: { url },
    } = this.props;

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

    const notificationGroups = Object.entries(notifications).map(
      ([key, group]) => ({
        panelkey: key,
        panelName: key,
        notifications: group,
      })
    );

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
        <ToggleIcon
          hasUnreadMessages={hasUnreadMessages}
          onClick={toggleDrawer}
        />
        {isReady && isDrawerOpen && (
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

notificationContainer.propTypes = {
  data: PropTypes.shape({
    url: PropTypes.string.isRequired,
  }).isRequired,
  isDrawerOpen: PropTypes.bool,
  isReady: PropTypes.bool,
  notifications: PropTypes.object,
  expandedGroup: PropTypes.string,
  hasUnreadMessages: PropTypes.bool,
  clickedLink: PropTypes.func,
  startNotificationsPolling: PropTypes.func,
  toggleDrawer: PropTypes.func,
  expandGroup: PropTypes.func,
  markAsRead: PropTypes.func,
  markGroupAsRead: PropTypes.func,
  clearNotification: PropTypes.func,
  clearGroup: PropTypes.func,
};

notificationContainer.defaultProps = {
  isDrawerOpen: false,
  isReady: false,
  notifications: {},
  expandedGroup: null,
  hasUnreadMessages: false,
  clickedLink: noop,
  startNotificationsPolling: noop,
  toggleDrawer: noop,
  expandGroup: noop,
  markAsRead: noop,
  markGroupAsRead: noop,
  clearNotification: noop,
  clearGroup: noop,
};

const mapStateToProps = state => {
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

export default connect(
  mapStateToProps,
  NotificationActions
)(onClickOutside(notificationContainer));
