import React from 'react';
import CommonForm from './CommonForm';

const Select = (props) => {
  return (
    <CommonForm label={props.label}>
      <select className="form-control"
              value={props.value}
              onChange={props.onChange}
      >
        <option value="">{__('Please select')}</option>
        {props.options}
      </select>
    </CommonForm>
  );
};

export default Select;
