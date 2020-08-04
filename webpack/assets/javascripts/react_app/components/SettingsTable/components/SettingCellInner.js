import React from 'react';
import classNames from 'classnames';
import PropTypes from 'prop-types';

import { valueToString, hasDefault, inStrong } from '../SettingsTableHelpers';

const SettingCellInner = props => {
  const { setting, className, onEditClick, ...rest } = props;

  const cssClasses = classNames(className, {
    'editable-empty': !setting.value && setting.settingsType !== 'boolean',
    'masked-input': setting.encrypted,
  });

  const field = (
    <span {...rest} className={cssClasses} onClick={() => onEditClick(setting)}>
      {valueToString(setting)}
    </span>
  );

  return setting.value !== setting.default && hasDefault(setting)
    ? inStrong(field)
    : field;
};

SettingCellInner.propTypes = {
  setting: PropTypes.object.isRequired,
  className: PropTypes.string,
  onEditClick: PropTypes.func.isRequired,
};

SettingCellInner.defaultProps = {
  className: '',
};

export default SettingCellInner;
