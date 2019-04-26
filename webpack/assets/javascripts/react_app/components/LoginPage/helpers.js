export const adjustAlerts = (alertType, alertMessage) => {
  let submitError = null;
  let alert = null;
  if (alertType === 'error') {
    submitError = alertMessage;
  } else {
    alert = {
      type: alertType,
      message: alertMessage,
      show: !!alertMessage,
    };
  }
  return {
    alert,
    submitError,
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
};
