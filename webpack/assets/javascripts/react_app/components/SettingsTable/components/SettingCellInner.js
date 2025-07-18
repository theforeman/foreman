import React from 'react';
import PropTypes from 'prop-types';
import { useDispatch } from 'react-redux';

import { setSettingEditing } from '../../SettingRecords/SettingRecordsActions';
import useSettingModal from '../../SettingUpdateModal/useSettingModal';

import { valueToString, hasDefault } from '../SettingsTableHelpers';

const SettingCellInner = props => {
  const { setting, ...rest } = props;

  const { setModalOpen } = useSettingModal();
  const dispatch = useDispatch();

  const editable = !setting.readonly;
  const openModal = () => {
    dispatch(setSettingEditing(setting));
    setModalOpen();
  };

  let field = (
    <div onClick={editable ? openModal : undefined} {...rest}>
      {valueToString(setting)}
    </div>
  );

  if (setting.value !== setting.default && hasDefault(setting))
    field = <strong>{field}</strong>;
  return field;
};

SettingCellInner.propTypes = {
  setting: PropTypes.object.isRequired,
};

export default SettingCellInner;
