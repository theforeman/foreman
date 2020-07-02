import React from 'react';
import PropTypes from 'prop-types';
import { Field } from 'formik';
import TextFieldInner from './TextFieldInner';

const TextField = ({
  name,
  label,
  type,
  className,
  inputClassName,
  required,
  validate,
  helpBlock,
}) => (
  <Field
    name={name}
    validate={validate}
    render={({ field, form: { touched, errors } }) => (
      <TextFieldInner
        input={{ ...field, value: field.value || '' }}
        meta={{ touched: touched[name], error: errors[name] }}
        name={name}
        type={type}
        required={required}
        className={className}
        inputClassName={inputClassName}
        label={label}
        helpBlock={helpBlock}
      />
    )}
  />
);

TextField.propTypes = {
  name: PropTypes.string.isRequired,
  label: PropTypes.string,
  type: PropTypes.string,
  className: PropTypes.string,
  inputClassName: PropTypes.string,
  required: PropTypes.oneOfType([PropTypes.bool, PropTypes.string]),
  validate: PropTypes.func,
  helpBlock: PropTypes.string,
};

TextField.defaultProps = {
  label: '',
  type: 'text',
  className: '',
  required: false,
  inputClassName: undefined,
  validate: undefined,
  helpBlock: null,
};

export default TextField;
