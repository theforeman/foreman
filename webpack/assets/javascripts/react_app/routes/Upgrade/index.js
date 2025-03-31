import React from 'react';
import UpgradePage from './UpgradePage';
import { UPGRADE_PATH } from './constants';

export default {
  path: UPGRADE_PATH,
  render: props => <UpgradePage {...props} />,
  exact: true,
};
