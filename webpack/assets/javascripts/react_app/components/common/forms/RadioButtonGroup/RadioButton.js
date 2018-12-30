import React from 'react';
import PropTypes from 'prop-types';
import { Radio } from 'patternfly-react';

const RadioButton = ({ input, item, disabled }) => (
  <Radio
    {...input}
    inline
    title={item.label}
    checked={item.checked}
    disabled={disabled}
    value={item.value}
  >
    {item.label}
  </Radio>
);

RadioButton.propTypes = {
  input: PropTypes.object.isRequired,
  item: PropTypes.shape({
    label: PropTypes.node,
    value: PropTypes.string,
    checked: PropTypes.bool,
  }),
  disabled: PropTypes.bool,
};

RadioButton.defaultProps = {
  item: {
    label: '',
    value: '',
    checked: false,
  },
  disabled: false,
};

export default RadioButton;
