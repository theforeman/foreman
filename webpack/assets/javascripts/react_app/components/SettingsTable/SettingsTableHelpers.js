import React from 'react';

import { Tooltip, OverlayTrigger } from 'patternfly-react';

import { translate as __ } from '../../common/I18n';

import { deepPropsToCamelCase } from '../../common/helpers';

export const withTooltip = Component => componentProps => {
  const { tooltipId, tooltipText, ...rest } = componentProps;

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

  const [, model] = setting[attr].split('-');

  const selectGroup = selectValues.find(group => group.groupLabel === model);

  if (!selectGroup) {
    return null;
  }

  const selectedItem = selectGroup.children.find(
    item => item.value === setting[attr]
  );

  return selectedItem && selectedItem.label;
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
  formatEmptyValue,
  formatTextValue,
]);

export const defaultToString = reduceFormats([
  formatEncryptedDefault,
  formatBooleanDefault,
  formatArrayDefault,
  formatArraySelectionDefault,
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

export const inStrong = markup => <strong>{markup}</strong>;
