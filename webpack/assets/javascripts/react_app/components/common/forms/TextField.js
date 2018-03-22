import React from 'react';
import { Field } from 'redux-form';
import CommonForm from './CommonForm';
import '../../../common/reduxFormI18n';

const renderField = ({
  input,
  label,
  type,
  required,
  className,
  inputClassName,
  meta: { touched, error },
}) => (
  <CommonForm
    label={label}
    className={className}
    inputClassName={inputClassName}
    touched={touched}
    required={required}
    error={error}
  >
    {type === 'textarea' ? (
      <textarea {...input} className="form-control" />
    ) : (
      <input {...input} type={type} className={type === 'checkbox' ? '' : 'form-control'} />
    )}
  </CommonForm>
);

const TextField = ({
  name,
  label,
  type = 'text',
  className = '',
  inputClassName,
  required,
  validate,
}) => (
  <Field
    name={name}
    type={type}
    component={renderField}
    required={required}
    className={className}
    inputClassName={inputClassName}
    label={label}
    validate={validate}
  />
);

export default TextField;
