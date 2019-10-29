import onClickOutside from 'react-onclickoutside';
import React from 'react';
import PropTypes from 'prop-types';
import {
  NotificationDrawerWrapper,
  NotificationDrawerPanelWrapper,
} from 'patternfly-react';
import { noop, translateObject } from '../../common/helpers';
import ToggleIcon from './components/ToggleIcon';
import { NOTIFICATIONS } from '../../redux/consts';
import './notifications.scss';

class Notifications extends React.Component {
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

  componentWillUnmount() {
    const { stopPolling } = this.props;
    stopPolling(NOTIFICATIONS);
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
      translations,
    } = this.props;

    const notificationGroups = Object.entries(notifications).map(
      ([key, group]) => ({
        panelkey: key,
        panelName: key,
        notifications: group,
      })
    );

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
            translations={translateObject(translations)}
          />
        )}
      </div>
    );
  }
}

Notifications.propTypes = {
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
  stopPolling: PropTypes.func,
  translations: PropTypes.shape({
    title: PropTypes.string,
    unreadEvent: PropTypes.string,
    unreadEvents: PropTypes.string,
    emptyState: PropTypes.string,
    readAll: PropTypes.string,
    clearAll: PropTypes.string,
    deleteNotification: PropTypes.string,
  }),
};

Notifications.defaultProps = {
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
  stopPolling: noop,
  translations: NotificationDrawerPanelWrapper.defaultProps.translations,
};

export default onClickOutside(Notifications);
