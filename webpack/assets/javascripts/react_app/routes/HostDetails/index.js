import React from 'react';
import HostDetails from '../../components/HostDetails';
import { HOST_DETAILS_PATH } from './constants';

export default {
  path: HOST_DETAILS_PATH,
  exact: true,
  render: props => <HostDetails {...props} />,
};
