import React from 'react';
import PropTypes from 'prop-types';

import { Table } from '../common/table';

import createSettingsTableSchema from './SettingsTableSchema';

const SettingsTable = ({ settings, onEditClick }) => (
  <Table
    key="settings-table"
    columns={createSettingsTableSchema(onEditClick)}
    rows={settings}
  />
);

SettingsTable.propTypes = {
  settings: PropTypes.array.isRequired,
  onEditClick: PropTypes.func.isRequired,
};

export default SettingsTable;
