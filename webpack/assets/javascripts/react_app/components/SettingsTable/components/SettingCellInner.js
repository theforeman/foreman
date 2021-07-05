import React from 'react';
import classNames from 'classnames';
import PropTypes from 'prop-types';
import EllipsisWithTooltip from 'react-ellipsis-with-tooltip';
import { useDispatch } from 'react-redux';

import { setSettingEditing } from '../../SettingRecords/SettingRecordsActions';
import useSettingModal from '../../SettingUpdateModal/useSettingModal';

import { valueToString, hasDefault, inStrong } from '../SettingsTableHelpers';

const SettingCellInner = props => {
  const { setting, className, ...rest } = props;

  const cssClasses = classNames(className, {
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

  const field = (
    <span
      onClick={editable ? openModal : undefined}
      {...rest}
      className={cssClasses}
    >
      {valueToString(setting)}
    </span>
  );

  const value =
    setting.value !== setting.default && hasDefault(setting)
      ? inStrong(field)
      : field;
  return <EllipsisWithTooltip>{value}</EllipsisWithTooltip>;
};

SettingCellInner.propTypes = {
  setting: PropTypes.object.isRequired,
  className: PropTypes.string,
};

SettingCellInner.defaultProps = {
  className: '',
};

export default SettingCellInner;
