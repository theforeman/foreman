import React from '@theforeman/vendor/react';
import PropTypes from '@theforeman/vendor/prop-types';
import { Field } from '@theforeman/vendor/redux-form';
import TextFieldInner from './TextFieldInner';
import '../../../../common/reduxFormI18n';

const TextField = ({
  name,
  label,
  type,
  className,
  inputClassName,
  required,
  validate,
}) => (
  <Field
    name={name}
    type={type}
    component={TextFieldInner}
    required={required}
    className={className}
    inputClassName={inputClassName}
    label={label}
    validate={validate}
  />
);

TextField.propTypes = {
  name: PropTypes.string.isRequired,
  label: PropTypes.string,
  type: PropTypes.string,
  className: PropTypes.string,
  inputClassName: PropTypes.string,
  required: PropTypes.oneOfType([PropTypes.bool, PropTypes.string]),
  validate: PropTypes.arrayOf(PropTypes.func),
};

TextField.defaultProps = {
  label: '',
  type: 'text',
  className: '',
  required: false,
  inputClassName: undefined,
  validate: undefined,
};

export default TextField;
