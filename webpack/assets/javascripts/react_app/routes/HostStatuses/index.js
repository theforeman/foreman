import React from 'react';
import HostStatuses from '../../components/HostStatuses';
import { HOST_STATUSES_PATH } from './constants';

export default {
  path: HOST_STATUSES_PATH,
  render: props => <HostStatuses {...props} />,
};
