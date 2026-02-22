import React, { useEffect } from 'react';
import PropTypes from 'prop-types';
import { Radio } from 'patternfly-react';
import { deprecate } from '../../../../common/DeprecationService';

const RadioButton = ({ input, item, disabled, checked }) => {
  useEffect(() => {
    deprecate(
      'forms/RadioButtonGroup',
      'Radio from @patternfly/react-core',
      '3.21'
    );
  }, []);

  return (
    <Radio
      {...input}
      inline
      title={item.label}
      checked={checked}
      disabled={disabled}
      value={item.value}
    >
      {item.label}
    </Radio>
  );
};

RadioButton.propTypes = {
  input: PropTypes.object.isRequired,
  item: PropTypes.shape({
    label: PropTypes.node,
    value: PropTypes.string,
  }),
  checked: PropTypes.bool,
  disabled: PropTypes.bool,
};

RadioButton.defaultProps = {
  item: {
    label: '',
    value: '',
  },
  checked: false,
  disabled: false,
};

export default RadioButton;
