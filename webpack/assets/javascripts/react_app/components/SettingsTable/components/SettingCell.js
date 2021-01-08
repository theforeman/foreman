import React from 'react';
import PropTypes from 'prop-types';

import { sprintf, translate as __ } from '../../../common/I18n';

import { withTooltip, defaultToString } from '../SettingsTableHelpers';

import SettingCellInner from './SettingCellInner';

import './SettingCell.scss';

const SettingCell = ({ setting, onEditClick }) => {
  const fieldProps = { setting, tooltipId: setting.name, onEditClick };
  const displayName = setting.fullName || setting.name;
  const defaultStr = defaultToString(setting);

  if (setting.readonly) {
    fieldProps.tooltipText = sprintf(
      __(
        'This setting is defined in the configuration file %s and is read-only.'
      ),
      setting.configFile
    );
  } else {
    fieldProps.tooltipText = `${displayName} (Default: ${defaultStr})`;
    fieldProps.className = 'editable';
  }

  const Component = withTooltip(SettingCellInner);
  return <Component {...fieldProps} />;
};

SettingCell.propTypes = {
  setting: PropTypes.object.isRequired,
  onEditClick: PropTypes.func,
};

SettingCell.defaultProps = {
  onEditClick: () => {},
};

export default SettingCell;
