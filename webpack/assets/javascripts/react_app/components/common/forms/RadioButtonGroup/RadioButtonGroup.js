import React from '@theforeman/vendor/react';
import PropTypes from '@theforeman/vendor/prop-types';
import { Field } from '@theforeman/vendor/redux-form';

import CommonForm from '../CommonForm';
import RadioButton from './RadioButton';

const RadioButtonGroup = ({
  controlLabel,
  radios,
  name,
  className,
  inputClassName,
  disabled,
}) => (
  <CommonForm
    label={controlLabel}
    className={className}
    inputClassName={inputClassName}
  >
    {radios.map((item, index) => (
      <Field
        name={name}
        component={RadioButton}
        item={item}
        disabled={disabled}
        key={index}
      />
    ))}
  </CommonForm>
);

RadioButtonGroup.propTypes = {
  controlLabel: PropTypes.string.isRequired,
  name: PropTypes.string.isRequired,
  className: PropTypes.string,
  inputClassName: PropTypes.string,
  disabled: PropTypes.bool,
  radios: PropTypes.arrayOf(
    PropTypes.shape({
      value: PropTypes.string,
      label: PropTypes.string,
      checked: PropTypes.bool,
    })
  ),
};

RadioButtonGroup.defaultProps = {
  radios: [],
  className: '',
  inputClassName: 'col-md-6',
  disabled: false,
};

export default RadioButtonGroup;
