import React from 'react';
import RegistrationCommandsPage from './RegistrationCommandsPage';
import { REGISTRATION_PATH } from './constants';

export default {
  path: REGISTRATION_PATH,
  render: props => <RegistrationCommandsPage {...props} />,
  exact: true,
};
