import React, { Component } from 'react';
import ToastNotificationsStore from '../../../stores/ToastNotificationsStore';
import Fade from '../../common/Fade';
import Toast from './Toast';
import helpers from '../../../common/helpers';

class ToastNotificationsContainer extends Component {
  constructor(props) {
    super(props);
    this.state = { notifications: [] };
    helpers.bindMethods(this, ['onChange']);
  }

  componentDidMount() {
    ToastNotificationsStore.addChangeListener(this.onChange);
    ToastNotificationsStore.getNotifications();
  }

  componentWillUnmount() {
    ToastNotificationsStore.removeChangeListener(this.onChange);
  }

  onChange(actionType) {
    this.setState({
      notifications: ToastNotificationsStore.getNotifications()
    });
  }

  render() {
    return (
      <div className="toast-notifications-list-pf">
        {this.state.notifications.map((notification, index) =>
          <Fade sticky={notification.sticky}>
            <Toast {...notification} key={index}/>
          </Fade>
        )}
      </div>
    );
  }
}

export default ToastNotificationsContainer;
