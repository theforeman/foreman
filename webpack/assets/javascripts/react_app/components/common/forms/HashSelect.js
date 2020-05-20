import React from 'react';
import PropTypes from 'prop-types';

import { FormControl } from 'patternfly-react';

const HashSelect = ({ field, model }) => (
  <FormControl name="value" componentClass="select" {...field}>
    {Object.entries(model.selectValues.collection).map(([key, val]) => (
      <option key={key} value={val}>
        {val}
      </option>
    ))}
  </FormControl>
);

HashSelect.propTypes = {
  field: PropTypes.object.isRequired,
  model: PropTypes.object.isRequired,
};

export default HashSelect;
