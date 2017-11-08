import React from 'react';
import CommonForm from './CommonForm';

const Checkbox = ({
  className = '', checked, onChange, label, disabled,
}) => (
  <CommonForm label={label} className={`common-checkbox ${className}`}>
    <input disabled={disabled} type="checkbox" checked={checked} onChange={onChange} />
  </CommonForm>
);

export default Checkbox;
