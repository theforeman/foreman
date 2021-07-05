import React from 'react';
import PropTypes from 'prop-types';

import { Table } from '../common/table';

import createSettingsTableSchema from './SettingsTableSchema';

const SettingsTable = ({ settings }) => (
  <Table
    key="settings-table"
    columns={createSettingsTableSchema}
    rows={settings}
  />
);

SettingsTable.propTypes = {
  settings: PropTypes.array.isRequired,
};

export default SettingsTable;
