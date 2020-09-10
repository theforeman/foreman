import { translate as __ } from '../../common/I18n';

export const adjustAlerts = alerts => {
  const submitErrors = [];
  const modifiedAlerts = [];

  alerts &&
    Object.keys(alerts).forEach(alertType => {
      const alertMessage = alerts[alertType];
      if (alertType === 'error') {
        submitErrors.push(alertMessage);
      } else if (alertMessage) {
        modifiedAlerts.push({
          type: alertType,
          message: alertMessage,
          show: true,
        });
      }
    });

  return {
    modifiedAlerts,
    submitErrors,
  };
};

export const defaultFormProps = {
  attributes: {
    action: '/users/login',
    method: 'post',
  },
  validate: true,
  topErrorOnly: true,
  usernameField: {
    id: 'login_login',
    attributes: {
      name: 'login[login]',
      autoFocus: true,
    },
    type: 'text',
    placeholder: __('Username'),
  },
  passwordField: {
    id: 'login_password',
    attributes: {
      name: 'login[password]',
    },
    type: 'password',
    placeholder: __('Password'),
  },
  submitText: __('Log In'),
  submitButtonAttributes: {
    id: 'login_submit_btn',
    name: 'commit',
  },
};
