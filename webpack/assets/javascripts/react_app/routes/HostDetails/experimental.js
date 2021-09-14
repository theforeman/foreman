import React from 'react';
import HostDetailsPage from '../../components/HostDetails/HostDetailsPage';
import { HOST_DETAILS_EXPERIMENTAL_PATH } from './constants';

export default {
  path: HOST_DETAILS_EXPERIMENTAL_PATH,
  render: props => <HostDetailsPage {...props} />,
};
