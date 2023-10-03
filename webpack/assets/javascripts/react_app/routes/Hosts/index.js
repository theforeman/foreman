import React from 'react';

import HostsIndex from '../../components/HostsIndex';
import { HOSTS_PATH } from './constants';

export default {
  path: HOSTS_PATH,
  render: props => <HostsIndex {...props} />,
  exact: true,
};
