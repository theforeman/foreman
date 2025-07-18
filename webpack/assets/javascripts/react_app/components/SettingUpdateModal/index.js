import React from 'react';
import { useSelector } from 'react-redux';

import useSettingModal from './useSettingModal';

import SettingUpdateModal from './SettingUpdateModal';

import { selectSettingEditing } from '../SettingRecords/SettingRecordsSelectors';

const WrappedSettingUpdateModal = props => {
  const setting = useSelector(state => selectSettingEditing(state)) || {};

  const { setModalClosed } = useSettingModal();

  return (
    <SettingUpdateModal setting={setting} setModalClosed={setModalClosed} />
  );
};

export default WrappedSettingUpdateModal;
