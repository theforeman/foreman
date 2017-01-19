import React, { Component } from 'react';
import helpers from '../../common/helpers';
import NotificationsStore from '../../stores/NotificationsStore';
import NotificationActions from '../../actions/NotificationActions';
import { ACTIONS } from '../../constants';

class NotificationDrawerToggle extends Component {
  constructor(props) {
    super(props);
    this.state = { count: 0, isLoaded: false, drawerOpen: false };
    helpers.bindMethods(this, ['onChange', 'onClick']);
  }

  componentDidMount() {
    NotificationsStore.addChangeListener(this.onChange);
    // NotificationsStore.addErrorListener(this.onError);
    NotificationActions.getNotifications(this.props.url);
  }

  onChange(actionType) {
    switch (actionType) {
      case ACTIONS.RECEIVED_NOTIFICATIONS: {
        this.setState({
          count: NotificationsStore.getNotifications().length,
          isLoaded: true
        });
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
    return this.state.count === 0 ? 'fa-bell-o' : 'fa-bell';
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
