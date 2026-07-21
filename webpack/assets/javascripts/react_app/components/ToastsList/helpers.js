/* eslint-disable no-console */

import { AlertVariant } from '@patternfly/react-core';

export const toastType = type => {
  if (type in AlertVariant) return type;

  console.warn(
    `Toast notification type '${type}' is invalid. Please use one of the following types: ${Object.values(
      AlertVariant
    )}`
  );

  const fallbackTypes = {
    alert: AlertVariant.warning,
    notice: AlertVariant.info,
    error: AlertVariant.danger,
  };

  return fallbackTypes[type] || AlertVariant.custom;
};

export const MAX_TOAST_TITLE_LENGTH = 60;

export const toastTitle = (message, type) => {
  if (message.length <= MAX_TOAST_TITLE_LENGTH) return message;
  return defaultTitle(type);
};

const defaultTitle = type => {
  switch (type) {
    case 'danger':
    case 'error':
      return 'Error';
    case 'warning':
      return 'Warning';
    case 'success':
      return 'Success';
    default:
      return 'Info';
  }
};
