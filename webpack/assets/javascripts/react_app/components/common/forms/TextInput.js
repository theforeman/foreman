import React from 'react';
import PropTypes from 'prop-types';
import CommonForm from './CommonForm';
import { makeOnChangeHanler } from './helpers';
import { noop } from '../../../common/helpers';

const TextInput = ({ label, className, value, onChange, onValueChange }) => (
  <CommonForm label={label} className={`common-textInput ${className}`}>
    <input
      type="text"
      className="form-control"
      value={value}
      onChange={makeOnChangeHanler(onChange, onValueChange)}
    />
  </CommonForm>
);

TextInput.propTypes = {
  label: PropTypes.string,
  className: PropTypes.string,
  value: PropTypes.string,
  onChange: PropTypes.func,
  onValueChange: PropTypes.func,
};

TextInput.defaultProps = {
  label: '',
  className: '',
  value: '',
  onChange: noop,
  onValueChange: noop,
};

export default TextInput;
