import React, { Component } from 'react';
import helpers from '../../common/helpers';
import NotificationsStore from '../../stores/NotificationsStore';
import NotificationActions from '../../actions/NotificationActions';
import { ACTIONS } from '../../constants';
import _ from 'lodash';

class NotificationDrawerToggle extends Component {
  constructor(props) {
    super(props);
    this.state = { isLoaded: false, drawerOpen: false, hasUnreadNotifications: false};
    helpers.bindMethods(this, ['onChange', 'onClick']);
  }

  componentDidMount() {
    NotificationsStore.addChangeListener(this.onChange);
    NotificationActions.getNotifications(this.props.url);
  }

  componentWillUnmount() {
    NotificationsStore.removeChangeListener(this.onChange);
  }

  onChange(actionType) {
    switch (actionType) {
      case ACTIONS.RECEIVED_NOTIFICATIONS: {
        const notifications = NotificationsStore.getNotifications();

        const newState = {
          hasUnreadNotifications: _.some(notifications, group =>
            _.some(group, notification => !notification.seen)),
          isLoaded: true
        };

        this.setState(newState);
        break;
      }
      case ACTIONS.NOTIFICATIONS_DRAWER_TOGGLE: {
        this.setState({
          drawerOpen: NotificationsStore.getIsDrawerOpen()
        });
        break;
      }
      default:
        break;
    }
  }

  onClick() {
    NotificationActions.toggleNotificationDrawer();
  }

  iconType() {
    return this.state.hasUnreadNotifications ? 'fa-bell' : 'fa-bell-o';
  }

  render() {
    return (
      <a className="nav-item-iconic drawer-pf-trigger-icon" onClick={this.onClick}>
        <span className={'fa ' + this.iconType()} title={__('Notifications')}></span>
      </a>
    );
  }
}

export default NotificationDrawerToggle;
