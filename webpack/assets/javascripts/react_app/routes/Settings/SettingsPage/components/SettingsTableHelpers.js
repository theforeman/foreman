import React from 'react';

import { Tooltip, OverlayTrigger } from 'patternfly-react';

import { translate as __ } from '../../../../common/I18n';

export const withTooltip = Component => props => {
  const { tooltipId, tooltipText, ...rest } = props;

  return (
    <OverlayTrigger
      overlay={<Tooltip id={tooltipId}>{tooltipText}</Tooltip>}
      trigger={['hover', 'focus']}
      placement="top"
      rootClose={false}
    >
      <span>
        <Component {...rest} />
      </span>
    </OverlayTrigger>
  );
};

const formatBoolean = setting => {
  if (setting.settingsType === 'boolean') {
    if (setting.value) {
      return __('Yes');
    }
    return __('No');
  }
  return null;
};

const formatArray = setting => {
  if (setting.settingsType === 'array') {
    return `[ ${setting.value ? setting.value.join(', ') : ''} ]`;
  }
  return null;
};

const formatText = setting => setting.value;

const formatEmptyDefaultValue = setting => {
  if (!setting.value) {
    return __('Not set');
  }
  return null;
};

const formatEmptyValue = setting => {
  if (!setting.value) {
    return __('Empty');
  }
  return null;
};

const reduceFormats = formatters => setting =>
  formatters.reduce((memo, formatter) => {
    if (memo) {
      return memo;
    }
    return formatter.call(this, setting);
  }, null);

export const valueToString = reduceFormats([
  formatBoolean,
  formatArray,
  formatEmptyValue,
  formatText,
]);

export const defaultToString = reduceFormats([
  formatBoolean,
  formatArray,
  formatEmptyDefaultValue,
  formatText,
]);

export const hasDefault = setting => {
  switch (setting.settingsType) {
    case 'boolean':
    case 'integer': {
      return true;
    }
    case 'array':
    case 'hash':
    case 'string': {
      return !!setting.default && setting.default.length !== 0;
    }
    default: {
      return !!setting.default;
    }
  }
};

export const inStrong = markup => <strong>{markup}</strong>;
