import React from 'react';
import { useSelector } from 'react-redux';

import useSettingModal from './useSettingModal';

import SettingUpdateModal from './SettingUpdateModal';

import { selectSettingToEdit } from '../SettingsTable/SettingsTableSelectors';

const WrappedSettingUpdateModal = props => {
  const toUpdate = useSelector(state => selectSettingToEdit(state));

  const { setModalClosed } = useSettingModal();

  return (
    <SettingUpdateModal setting={toUpdate} setModalClosed={setModalClosed} />
  );
};

export default WrappedSettingUpdateModal;
