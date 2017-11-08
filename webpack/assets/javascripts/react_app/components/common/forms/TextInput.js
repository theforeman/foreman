import React from 'react';
import CommonForm from './CommonForm';

const TextInput = ({
  label, className = '', value, onChange,
}) => (
  <CommonForm label={label} className={`common-textInput ${className}`}>
    <input type="text" className="form-control" value={value} onChange={onChange} />
  </CommonForm>
);

export default TextInput;
