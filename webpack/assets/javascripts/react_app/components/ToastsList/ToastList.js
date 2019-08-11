import React from 'react';
import {
  ToastNotificationList,
  ToastNotification,
  TimedToastNotification,
} from 'patternfly-react';
import PropTypes from 'prop-types';
import { noop } from '../../common/helpers';
import AlertBody from '../common/Alert/AlertBody';

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
