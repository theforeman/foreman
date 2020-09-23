import React from 'react';
import { useSelector, useDispatch } from 'react-redux';
import PropTypes from 'prop-types';

import { selectSettingsByCategory } from '../SettingRecords/SettingRecordsSelectors';

import { setSettingEditing } from '../SettingRecords/SettingRecordsActions';

import SettingsTable from './SettingsTable';

import useSettingModal from '../SettingUpdateModal/useSettingModal';

const WrappedSettingsTable = props => {
  const settings = useSelector(state =>
    selectSettingsByCategory(props.category)(state)
  );

  const dispatch = useDispatch();
  const { setModalOpen } = useSettingModal();

  const onEditClick = async setting => {
    await dispatch(setSettingEditing(setting));
    setModalOpen();
  };

  return <SettingsTable settings={settings} onEditClick={onEditClick} />;
};

WrappedSettingsTable.propTypes = {
  category: PropTypes.string.isRequired,
};

export default WrappedSettingsTable;
