import React from 'react';
import classNames from 'classnames';
import PropTypes from 'prop-types';
import { useDispatch } from 'react-redux';

import { setSettingEditing } from '../../SettingRecords/SettingRecordsActions';
import useSettingModal from '../../SettingUpdateModal/useSettingModal';

import { valueToString, hasDefault } from '../SettingsTableHelpers';

const SettingCellInner = props => {
  const { setting, className, ...rest } = props;

  const cssClasses = classNames(className, 'ellipsis', {
    'editable-empty': !setting.value && setting.settingsType !== 'boolean',
    'masked-input': setting.encrypted,
  });

  const { setModalOpen } = useSettingModal();
  const dispatch = useDispatch();

  const editable = !setting.readonly;
  const openModal = () => {
    dispatch(setSettingEditing(setting));
    setModalOpen();
  };

  let field = (
    <div
      onClick={editable ? openModal : undefined}
      {...rest}
      className={cssClasses}
    >
      {valueToString(setting)}
    </div>
  );

  if (setting.value !== setting.default && hasDefault(setting))
    field = <strong>{field}</strong>;
  return field;
};

SettingCellInner.propTypes = {
  setting: PropTypes.object.isRequired,
  className: PropTypes.string,
};

SettingCellInner.defaultProps = {
  className: '',
};

export default SettingCellInner;
