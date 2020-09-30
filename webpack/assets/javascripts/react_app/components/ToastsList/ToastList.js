import React from 'react';
import {
  ToastNotificationList,
  ToastNotification,
  TimedToastNotification,
  Alert,
} from 'patternfly-react';
import PropTypes from 'prop-types';
import { noop } from '../../common/helpers';
import AlertBody from '../common/Alert/AlertBody';

const toastType = type => {
  if (Alert.ALERT_TYPES.includes(type)) return type;
  const message = `Toast notification type '${type}' is invalid. Please use one of the following types: ${Alert.ALERT_TYPES}`;
  switch (type) {
    case 'alert':
      // eslint-disable-next-line no-console
      console.warn(message);
      return 'warning';
    case 'notice':
      // eslint-disable-next-line no-console
      console.warn(message);
      return 'info';
    default:
      // eslint-disable-next-line no-console
      console.error(message);
      return 'info';
  }
};

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
          type={toastType(toastProps.type)}
        >
          <AlertBody link={link} message={message} />
        </ToastComponent>
      );
    });
  return (
    toastsList.length > 0 && (
      <ToastNotificationList>{toastsList}</ToastNotificationList>
    )
  );
};

ToastsList.propTypes = {
  messages: PropTypes.object.isRequired,
  deleteToast: PropTypes.func,
};

ToastsList.defaultProps = {
  deleteToast: noop,
};

export default ToastsList;
