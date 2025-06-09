import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from '../../../common/I18n';
import { withTooltip } from '../SettingsTableHelpers';

const settingName = ({ setting }) => (
  <>{setting.fullName ? __(setting.fullName) : setting.name}</>
);

const SettingNameCell = ({ setting }) => {
  const NameWithTooltip = withTooltip(settingName);
  return (
    <NameWithTooltip
      setting={setting}
      tooltipId={setting.name}
      tooltipText={setting.name}
    />
  );
};

SettingNameCell.propTypes = {
  setting: PropTypes.object.isRequired,
};

export default SettingNameCell;
