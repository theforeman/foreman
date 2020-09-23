import React from 'react';
import PropTypes from 'prop-types';

import { sprintf, translate as __ } from '../../../common/I18n';

import { withTooltip, defaultToString } from '../SettingsTableHelpers';

import SettingCellInner from './SettingCellInner';

import './SettingCell.scss';

const SettingCell = props => {
  const fieldProps = { setting: props.setting, tooltipId: props.setting.name };

  if (props.setting.readonly) {
    fieldProps.tooltipText = sprintf(
      __(
        'This setting is defined in the configuration file %s and is read-only.'
      ),
      props.setting.configFile
    );
  } else {
    fieldProps.tooltipText = `${
      props.setting.fullName
    } (Default: ${defaultToString(props.setting)})`;
    fieldProps.className = 'editable';
  }

  fieldProps.onEditClick = props.onEditClick;

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
