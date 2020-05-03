import onClickOutside from 'react-onclickoutside';
import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { groupBy } from 'lodash';
import {
  NotificationDrawerWrapper,
  NotificationDrawerPanelWrapper,
} from 'patternfly-react';
import * as NotificationActions from '../../redux/actions/notifications';
import { noop, translateObject } from '../../common/helpers';

import './notifications.scss';
import ToggleIcon from './ToggleIcon/ToggleIcon';

class notificationContainer extends React.Component {
  componentDidMount() {
    const {
      getNotifications,
      data: { url },
    } = this.props;

    getNotifications(url);
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
  getNotifications: PropTypes.func,
  toggleDrawer: PropTypes.func,
  expandGroup: PropTypes.func,
  markAsRead: PropTypes.func,
  markGroupAsRead: PropTypes.func,
  clearNotification: PropTypes.func,
  clearGroup: PropTypes.func,
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

notificationContainer.defaultProps = {
  isDrawerOpen: false,
  isReady: false,
  notifications: {},
  expandedGroup: null,
  hasUnreadMessages: false,
  clickedLink: noop,
  getNotifications: noop,
  toggleDrawer: noop,
  expandGroup: noop,
  markAsRead: noop,
  markGroupAsRead: noop,
  clearNotification: noop,
  clearGroup: noop,
  translations: NotificationDrawerPanelWrapper.defaultProps.translations,
};

const mapStateToProps = state => {
  const {
    notifications,
    isDrawerOpen,
    expandedGroup,
    hasUnreadMessages,
  } = state.notifications;

  return {
    isDrawerOpen,
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
