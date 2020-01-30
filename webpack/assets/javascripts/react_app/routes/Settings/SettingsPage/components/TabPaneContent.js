import React from 'react';
import PropTypes from 'prop-types';

import { Table } from '../../../../components/common/table';
import createSettingsTableSchema from './SettingsTableSchema';

import TestEmail from './TestEmail';

const TabPaneContent = ({ category, settings, onEditClick }) => (
  <React.Fragment>
    {category === 'Setting::Email' ? <TestEmail /> : null}
    <Table
      key="settings-table"
      columns={createSettingsTableSchema(onEditClick)}
      rows={settings}
    />
  </React.Fragment>
);

TabPaneContent.propTypes = {
  category: PropTypes.string.isRequired,
  onEditClick: PropTypes.func.isRequired,
  settings: PropTypes.array.isRequired,
};

export default TabPaneContent;
