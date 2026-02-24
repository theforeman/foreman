import React from 'react';

import HostsIndexWrapper from '../../components/HostsIndex/HostsIndexWrapper';
import { HOSTS_PATH } from './constants';

export default {
  path: HOSTS_PATH,
  render: props => <HostsIndexWrapper {...props} />,
  exact: true,
};
