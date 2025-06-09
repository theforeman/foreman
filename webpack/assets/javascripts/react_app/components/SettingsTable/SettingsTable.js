import React from 'react';
import PropTypes from 'prop-types';

import { Table, Thead, Tr, Th, Tbody, Td } from '@patternfly/react-table';

import { translate as __ } from '../../common/I18n';
import SettingValueCell from './components/SettingValueCell';
import SettingNameCell from './components/SettingName';

const TableHead = () => (
  <Thead>
    <Tr ouiaId="setting-table-heading-row">
      <Th width={30}> {__('Name')} </Th>
      <Th width={35}> {__('Value')} </Th>
      <Th width={35}> {__('Description')} </Th>
    </Tr>
  </Thead>
);

const ViewRows = ({ settings }) =>
  settings.map((data, index) => (
    <Tr key={index} ouiaId={`setting-table-heading-row-${index}`}>
      <Td>
        <SettingNameCell setting={data} />
      </Td>
      <Td>
        <SettingValueCell setting={data} index={index} />
      </Td>
      <Td>{data.description}</Td>
    </Tr>
  ));

const SettingsTable = ({ settings }) => (
  <Table isStriped variant="compact" ouiaId="settings-table" borders>
    <TableHead />
    <Tbody>
      <ViewRows settings={settings} />
    </Tbody>
  </Table>
);
SettingsTable.propTypes = {
  settings: PropTypes.array.isRequired,
};

export default SettingsTable;
