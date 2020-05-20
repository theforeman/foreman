import React from 'react';
import PropTypes from 'prop-types';

import { FormControl } from 'patternfly-react';

const ArraySelect = ({ model, field }) => {
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
      {model.selectValues.collection.map((group, idx) => {
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

ArraySelect.propTypes = {
  model: PropTypes.object.isRequired,
  field: PropTypes.object.isRequired,
};

export default ArraySelect;
