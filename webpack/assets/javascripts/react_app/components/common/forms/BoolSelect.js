import React from 'react';
import PropTypes from 'prop-types';

import { FormControl } from 'patternfly-react';

const BoolSelect = ({ field }) => (
  <FormControl name="value" componentClass="select" {...field}>
    <option value>Yes</option>
    <option value={false}>No</option>
  </FormControl>
);

BoolSelect.propTypes = {
  field: PropTypes.object.isRequired,
};

export default BoolSelect;
