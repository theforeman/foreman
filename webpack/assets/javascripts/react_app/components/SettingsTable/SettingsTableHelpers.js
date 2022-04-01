import React from 'react';

import { Tooltip } from '@patternfly/react-core';
import { translate as __ } from '../../common/I18n';

import { deepPropsToCamelCase } from '../../common/helpers';

export const withTooltip = Component => componentProps => {
  const { tooltipId, tooltipText, ...rest } = componentProps;

  return (
    <Tooltip content={tooltipText}>
      {/* The span is needed because Tooltip overrides child events */}
      <span>
        <Component {...rest} />
      </span>
    </Tooltip>
  );
};

export const arraySelection = setting => {
  const { selectValues } = setting;

  if (!Array.isArray(selectValues)) {
    return null;
  }
  return deepPropsToCamelCase(selectValues);
};

const formatEncryptedDefault = setting => {
  if (setting.encrypted && setting.default) {
    return setting.default
      .split('')
      .map(item => '\u2219')
      .join('');
  }

  return null;
};

const formatHashSelectionDefault = setting =>
  formatHashSelection('default', setting);
const formatHashSelectionValue = setting =>
  formatHashSelection('value', setting);

const formatHashSelection = (attr, setting) => {
  const { selectValues } = setting;

  const val = setting[attr];

  if (!selectValues || !selectValues[val]) {
    return null;
  }

  return selectValues[val];
};

const formatBooleanDefault = setting => formatBoolean('default', setting);
const formatBooleanValue = setting => formatBoolean('value', setting);

const formatBoolean = (attr, setting) => {
  if (setting.settingsType === 'boolean') {
    if (setting[attr]) {
      return __('Yes');
    }
    return __('No');
  }
  return null;
};

const formatArrayValue = setting => formatArray('value', setting);
const formatArrayDefault = setting => formatArray('default', setting);

const formatArray = (attr, setting) => {
  if (setting.settingsType === 'array') {
    return `[${
      setting[attr] && setting[attr].length > 0 ? setting.value.join(', ') : ''
    }]`;
  }
  return null;
};

const formatTextValue = setting => setting.value;
const formatTextDefault = setting => setting.default;

const formatEmpty = (attr, emptyValue, setting) => {
  if (!setting[attr]) {
    return emptyValue;
  }
  return null;
};

const formatEmptyDefault = setting =>
  formatEmpty('default', __('Not set'), setting);
const formatEmptyValue = setting => formatEmpty('value', __('Empty'), setting);

const formatArraySelectionDefault = setting =>
  formatArraySelection('default', setting);
const formatArraySelectionValue = setting =>
  formatArraySelection('value', setting);

const formatArraySelection = (attr, setting) => {
  const selectValues = arraySelection(setting);

  if (!setting[attr] || !selectValues) {
    return null;
  }

  // https://github.com/eslint/eslint/issues/12117
  let group;
  for (group of selectValues) {
    if (group.value === setting[attr]) {
      return group.label;
    }

    if (group.children) {
      const child = group.children.find(item => item.value === setting[attr]);
      if (child) {
        return child.label;
      }
    }
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
  formatBooleanValue,
  formatArrayValue,
  formatArraySelectionValue,
  formatHashSelectionValue,
  formatEmptyValue,
  formatTextValue,
]);

export const defaultToString = reduceFormats([
  formatEncryptedDefault,
  formatBooleanDefault,
  formatArrayDefault,
  formatArraySelectionDefault,
  formatHashSelectionDefault,
  formatEmptyDefault,
  formatTextDefault,
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
