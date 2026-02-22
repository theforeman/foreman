import React from 'react';
import { deprecate } from '../../../common/DeprecationService';

const renderOption = (val, text, key = null) => {
  const optValue = val === null || val === undefined ? '' : val;

  return (
    <option value={optValue} key={key || val}>
      {text}
    </option>
  );
};

const renderOptGroup = group => (
  <optgroup label={group.groupLabel} key={group.groupLabel}>
    {renderOptions(group.children)}
  </optgroup>
);

export const renderOptions = opts => {
  deprecate(
    'forms/SelectHelpers',
    'Select from @patternfly/react-core',
    '3.21'
  );
  if (Array.isArray(opts)) {
    return opts.map((opt, index) => {
      if (opt.children) {
        return renderOptGroup(opt);
      }
      return renderOption(opt.value, opt.label, index);
    });
  }
  return Object.entries(opts).map(([val, text]) => renderOption(val, text));
};
