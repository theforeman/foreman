import { connect } from 'react-redux';
import React, { Component } from 'react';
import { ToastNotificationList, ToastNotification, TimedToastNotification } from 'patternfly-react';
import AlertBody from '../common/Alert/AlertBody';
import * as ToastActions from '../../redux/actions/toasts';

class ToastsList extends Component {
  render() {
    const { messages, deleteToast } = this.props;

    const toastsList = Object.entries(messages)
      .map(([key, message]) => ({ key, ...message }))
      .map(({
        key, link, message, sticky = false, ...toastProps
      }) => {
        const ToastComponent = sticky ? ToastNotification : TimedToastNotification;

        return (
          <ToastComponent key={key} onDismiss={() => deleteToast(key)} {...toastProps}>
            <AlertBody link={link} message={message} />
          </ToastComponent>
        );
      });

    return <ToastNotificationList>{toastsList}</ToastNotificationList>;
  }
}

const mapStateToProps = state => ({
  messages: state.toasts.messages,
});

export default connect(mapStateToProps, ToastActions)(ToastsList);
