import React from 'react';
import classNames from 'classnames';

import { withTooltip } from './SettingsTableHelpers';

import SettingName from './components/SettingName';
import SettingCell from './components/SettingCell';

export const settingNameCellFormatter = (value, { rowData }) => {
  const SettingNameWithTooltip = withTooltip(SettingName);

  return (
    <SettingNameWithTooltip
      setting={rowData}
      tooltipId={rowData.name}
      tooltipText={rowData.name}
    />
  );
};

export const settingValueCellFormatter = (value, { rowData: setting }) => {
  const cssClasses = classNames('ellipsis-pf-tooltip', {
    'editable-empty': !setting.value && setting.settingsType !== 'boolean',
    'masked-input': setting.encrypted,
    editable: !setting.readonly,
  });
  return <SettingCell value={value} setting={setting} className={cssClasses} />;
};
