import React from 'react';

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

export const settingValueCellFormatter = onEditClick => (
  value,
  { rowData }
) => <SettingCell value={value} setting={rowData} onEditClick={onEditClick} />;
