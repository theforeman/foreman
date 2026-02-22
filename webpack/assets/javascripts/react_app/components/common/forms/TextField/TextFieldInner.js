import React, { useEffect } from 'react';
import PropTypes from 'prop-types';
import CommonForm from '../CommonForm';
import { deprecate } from '../../../../common/DeprecationService';

const TextFieldInner = ({
  input,
  label,
  type,
  required,
  className,
  inputClassName,
  meta: { touched, error },
}) => {
  useEffect(() => {
    deprecate(
      'forms/TextFieldInner',
      'TextInput/TextArea from @patternfly/react-core',
      '3.21'
    );
  }, []);

  return (
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
        <input
          {...input}
          type={type}
          checked={type === 'checkbox' ? input.value : undefined}
          className={type === 'checkbox' ? '' : 'form-control'}
        />
      )}
    </CommonForm>
  );
};

TextFieldInner.propTypes = {
  input: PropTypes.object,
  label: PropTypes.string,
  type: PropTypes.string,
  required: PropTypes.oneOfType([PropTypes.bool, PropTypes.string]),
  className: PropTypes.string,
  inputClassName: PropTypes.string,
  meta: PropTypes.shape({ touched: PropTypes.bool, error: PropTypes.string }),
};

TextFieldInner.defaultProps = {
  input: {},
  label: '',
  type: 'text',
  className: '',
  required: false,
  inputClassName: undefined,
  meta: { touched: false, error: undefined },
};

export default TextFieldInner;
