import React from 'react';
import { useSelector } from 'react-redux';
import PropTypes from 'prop-types';

import { selectSettingsByCategory } from '../SettingRecords/SettingRecordsSelectors';

import SettingsTable from './SettingsTable';

const WrappedSettingsTable = (props) => {
  const settings = useSelector((state) =>
    selectSettingsByCategory(props.category)(state)
  );

  return <SettingsTable settings={settings} />;
};

WrappedSettingsTable.propTypes = {
  category: PropTypes.string.isRequired,
};

export default WrappedSettingsTable;
