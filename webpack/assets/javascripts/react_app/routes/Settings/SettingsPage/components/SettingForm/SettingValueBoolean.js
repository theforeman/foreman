import React from 'react';
import PropTypes from 'prop-types';

import { FormControl } from 'patternfly-react';

const SettingValueBoolean = ({ field }) => (
  <FormControl name="value" componentClass="select" {...field}>
    <option value>Yes</option>
    <option value={false}>No</option>
  </FormControl>
);

SettingValueBoolean.propTypes = {
  field: PropTypes.object.isRequired,
};

export default SettingValueBoolean;
