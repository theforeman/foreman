import React from 'react';
import PropTypes from 'prop-types';
import { Field } from 'redux-form';
import { Radio } from 'patternfly-react';
import CommonForm from './CommonForm';

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
        component={Button}
        item={item}
        disabled={disabled}
        key={index}
      />
    ))}
  </CommonForm>
);

const Button = ({ input, item, disabled }) => (
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

RadioButtonGroup.propTypes = {
  controlLabel: PropTypes.string.isRequired,
  name: PropTypes.string.isRequired,
  className: PropTypes.string,
  inputClassName: PropTypes.string,
  disabled: PropTypes.bool,
  radios: PropTypes.arrayOf(PropTypes.shape({
    value: PropTypes.string,
    label: PropTypes.string,
    checked: PropTypes.bool,
  })),
};

RadioButtonGroup.defaultProps = {
  radios: [],
  className: '',
  inputClassName: 'col-md-6',
  disabled: false,
};

export default RadioButtonGroup;
