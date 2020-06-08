import React from 'react';
import { useSelector, useDispatch } from 'react-redux';
import PropTypes from 'prop-types';

import { selectSettingsByCategory } from '../SettingRecords/SettingRecordsSelectors';

import { setSettingToUpdate } from './SettingsTableActions';

import SettingsTable from './SettingsTable';

import reducer from './SettingsTableReducer';

import useSettingModal from '../SettingUpdateModal/useSettingModal';

export const reducers = {
  settingsTable: reducer,
};

const WrappedSettingsTable = props => {
  const settings = useSelector(state =>
    selectSettingsByCategory(state, props.category)
  );

  const dispatch = useDispatch();
  const { setModalOpen } = useSettingModal();

  const onEditClick = async setting => {
    await dispatch(setSettingToUpdate(setting));
    setModalOpen();
  };

  return <SettingsTable settings={settings} onEditClick={onEditClick} />;
};

WrappedSettingsTable.propTypes = {
  category: PropTypes.string.isRequired,
};

export default WrappedSettingsTable;
