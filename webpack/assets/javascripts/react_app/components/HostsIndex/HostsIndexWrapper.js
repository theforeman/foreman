import React from 'react';
import Permitted from '../Permitted/Permitted';
import HostsIndex from './index';

const REQUIRED_PERMISSIONS = ['view_hosts'];

const HostsIndexWrapper = props => (
  <Permitted requiredPermissions={REQUIRED_PERMISSIONS}>
    <HostsIndex {...props} />
  </Permitted>
);

export default HostsIndexWrapper;
