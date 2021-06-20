import React from 'react';
import classNames from 'classnames';
import PropTypes from 'prop-types';
import EllipsisWithTooltip from 'react-ellipsis-with-tooltip';

import { valueToString, hasDefault, inStrong } from '../SettingsTableHelpers';

const SettingCellInner = props => {
  const { setting, className, onEditClick, ...rest } = props;

  const cssClasses = classNames(className, {
    'editable-empty': !setting.value && setting.settingsType !== 'boolean',
    'masked-input': setting.encrypted,
  });

  if (!setting.readonly)
    rest.onClick = () => onEditClick(setting);

  const field = (
    <span
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
  onEditClick: PropTypes.func.isRequired,
};

SettingCellInner.defaultProps = {
  className: '',
};

export default SettingCellInner;
