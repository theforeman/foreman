import React from 'react';
import HostsCountCell from '../components/HostsCountCell';

const hostsCountCellFormatter = controllerSingular => (
  value,
  { rowData: { name } }
) => (
  <HostsCountCell controller={controllerSingular} name={name}>
    {value}
  </HostsCountCell>
);

export default hostsCountCellFormatter;
