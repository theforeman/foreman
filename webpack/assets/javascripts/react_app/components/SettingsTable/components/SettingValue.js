import React from 'react';
import PropTypes from 'prop-types';
import { sprintf, translate as __ } from '../../../common/I18n';
import {
  hasDefault,
  withTooltip,
  defaultToString,
  valueToString,
} from '../SettingsTableHelpers';

const innerCell = props => {
  const { setting } = props;

  let field = (
    <div
      className={
        setting.value || setting.settingsType === 'boolean' ? '' : 'empty-value'
      }
    >
      {valueToString(setting)}
    </div>
  );

  if (setting.value !== setting.default && hasDefault(setting))
    field = <strong>{field}</strong>;
  return field;
};

const SettingValue = ({ setting }) => {
  const fieldProps = {
    setting,
    tooltipId: setting.name,
  };

  if (setting.readonly) {
    fieldProps.tooltipText = sprintf(
      __(
        'This setting is defined in the configuration file %s and is read-only.'
      ),
      setting.configFile
    );
  } else {
    const defaultStr = defaultToString(setting);
    fieldProps.tooltipText = sprintf(__('Default: %s'), defaultStr);
  }

  const Component = withTooltip(innerCell);
  return <Component {...fieldProps} />;
};

SettingValue.propTypes = {
  setting: PropTypes.object.isRequired,
  className: PropTypes.string,
};

SettingValue.defaultProps = {
  className: '',
};

export default SettingValue;
