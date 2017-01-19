import React, { Component } from 'react';
import helpers from '../../common/helpers';
import NotificationsStore from '../../stores/NotificationsStore';
import NotificationDrawerTitle from './NotificationDrawerTitle';
import NotificationAccordion from './NotificationAccordion';
import {ACTIONS} from '../../constants';

class NotificationDrawer extends Component {
  constructor(props) {
    super(props);
    this.state = {
      notifications: NotificationsStore.getNotifications(),
      drawerOpen: NotificationsStore.getIsDrawerOpen()
    };
    helpers.bindMethods(this, ['onChange']);
  }
  componentDidMount() {
    NotificationsStore.addChangeListener(this.onChange);
  }
  onChange(actionType) {
    switch (actionType) {
      case ACTIONS.RECEIVED_NOTIFICATIONS: {
        this.setState({ notifications: NotificationsStore.getNotifications() });
        break;
      }
      case ACTIONS.NOTIFICATIONS_DRAWER_TOGGLE: {
        const isOpen = NotificationsStore.getIsDrawerOpen();

        this.setState({
          drawerOpen: isOpen
        });
        break;
      }

      default:
        break;
    }
  }
  render() {
    // render title and accordion
    const toggleClass = this.state.drawerOpen ? '' : ' hide';

    return (
      <div className={'drawer-pf drawer-pf-notifications-non-clickable' + toggleClass}>
        <NotificationDrawerTitle text="Notifications" />
        <NotificationAccordion notifications={this.state.notifications} />
      </div>
    );
  }
}

export default NotificationDrawer;
