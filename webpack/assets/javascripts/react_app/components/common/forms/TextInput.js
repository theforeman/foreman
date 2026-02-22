import React, { useEffect } from 'react';
import PropTypes from 'prop-types';
import CommonForm from './CommonForm';
import { noop } from '../../../common/helpers';
import { deprecate } from '../../../common/DeprecationService';

const TextInput = ({ label, className, value, onChange }) => {
  useEffect(() => {
    deprecate(
      'forms/TextInput',
      'TextInput from @patternfly/react-core',
      '3.21'
    );
  }, []);

  return (
    <CommonForm label={label} className={`common-textInput ${className}`}>
      <input
        type="text"
        className="form-control"
        value={value}
        onChange={onChange}
      />
    </CommonForm>
  );
};

TextInput.propTypes = {
  label: PropTypes.string,
  className: PropTypes.string,
  value: PropTypes.string,
  onChange: PropTypes.func,
};

TextInput.defaultProps = {
  label: '',
  className: '',
  value: '',
  onChange: noop,
};

export default TextInput;
