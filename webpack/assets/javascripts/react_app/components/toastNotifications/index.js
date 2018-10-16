import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import {
  ToastNotificationList,
  ToastNotification,
  TimedToastNotification,
} from 'patternfly-react';
import AlertBody from '../common/Alert/AlertBody';
import * as ToastActions from '../../redux/actions/toasts';
import { noop } from '../../common/helpers';

const ToastsList = ({ messages, deleteToast }) => {
  const toastsList = Object.entries(messages)
    .map(([key, message]) => ({ key, ...message }))
    .map(({ key, link, message, sticky = false, ...toastProps }) => {
      const ToastComponent = sticky
        ? ToastNotification
        : TimedToastNotification;

      return (
        <ToastComponent
          key={key}
          onDismiss={() => deleteToast(key)}
          {...toastProps}
        >
          <AlertBody link={link} message={message} />
        </ToastComponent>
      );
    });

  return <ToastNotificationList>{toastsList}</ToastNotificationList>;
};

ToastsList.propTypes = {
  messages: PropTypes.object.isRequired,
  deleteToast: PropTypes.func,
};

ToastsList.defaultProps = {
  deleteToast: noop,
};

const mapStateToProps = state => ({
  messages: state.toasts.messages,
});

export default connect(
  mapStateToProps,
  ToastActions
)(ToastsList);
