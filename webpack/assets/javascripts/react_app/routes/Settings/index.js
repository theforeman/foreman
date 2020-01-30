import React from 'react';
import SettingsPage from './SettingsPage';
import { SETTINGS_PATH } from './constants';

export default {
  path: SETTINGS_PATH,
  render: props => <SettingsPage {...props} />,
};
