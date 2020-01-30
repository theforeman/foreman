import React from 'react';
import PropTypes from 'prop-types';

import { FormControl } from 'patternfly-react';

const SettingValueArraySelect = ({ setting, field }) => {
  const createOptgroup = group => (
    <optgroup label={group.groupLabel} key={group.groupLabel}>
      {group.children.map((item, index) => (
        <option value={item.value} key={index}>
          {item.label}
        </option>
      ))}
    </optgroup>
  );

  return (
    <FormControl name="value" componentClass="select" {...field}>
      {setting.selectValues.collection.map((group, idx) => {
        if (group.groupLabel && group.children) {
          return createOptgroup(group);
        }
        return (
          <option key={idx} value={group.value}>
            {group.label}
          </option>
        );
      })}
    </FormControl>
  );
};

SettingValueArraySelect.propTypes = {
  setting: PropTypes.object.isRequired,
  field: PropTypes.object.isRequired,
};

export default SettingValueArraySelect;
