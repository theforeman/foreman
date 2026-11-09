import React from 'react';
import HostsCountCell from '../components/HostsCountCell';
import { deprecate } from '../../../../common/DeprecationService';

let hostsCountCellFormatterDeprecationLogged = false;

const logHostsCountCellFormatterDeprecation = () => {
  if (hostsCountCellFormatterDeprecationLogged) {
    return;
  }

  hostsCountCellFormatterDeprecationLogged = true;
  deprecate(
    'table/formatters/hostsCountCellFormatter',
    'TableIndexPage from foremanReact/components/PF4/TableIndexPage/TableIndexPage or Table from @patternfly/react-table',
    '5.2'
  );
};

const hostsCountCellFormatter = controllerSingular => {
  logHostsCountCellFormatterDeprecation();

  return (value, { rowData: { name } }) => (
    <HostsCountCell controller={controllerSingular} name={name}>
      {value}
    </HostsCountCell>
  );
};

export default hostsCountCellFormatter;
