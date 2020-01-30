import React from 'react';
import PropTypes from 'prop-types';

import { FormControl } from 'patternfly-react';

const SettingValueHashSelect = ({ field, setting }) => (
  <FormControl name="value" componentClass="select" {...field}>
    {Object.entries(setting.selectValues.collection).map(([key, val]) => (
      <option key={key} value={val}>
        {val}
      </option>
    ))}
  </FormControl>
);

SettingValueHashSelect.propTypes = {
  field: PropTypes.object.isRequired,
  setting: PropTypes.object.isRequired,
};

export default SettingValueHashSelect;
