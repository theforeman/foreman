import React from 'react';
import {
  FormSelectOption,
  FormSelectOptionGroup,
} from '@patternfly/react-core';

const renderOption = (val, text, key = null) => {
  const optValue = val === null || val === undefined ? '' : val;

  return <FormSelectOption value={optValue} key={key || val} label={text} />;
};

const renderOptGroup = group => (
  <FormSelectOptionGroup label={group.groupLabel} key={group.groupLabel}>
    {renderPF5Options(group.children)}
  </FormSelectOptionGroup>
);

/**
 * @param opts
 * @returns {*|*[]} PatternFly FormSelect option elements
 */
export const renderPF5Options = opts => {
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
