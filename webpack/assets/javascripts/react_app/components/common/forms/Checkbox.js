import React from 'react';
import CommonForm from './CommonForm';

const Checkbox = (props) => {
  return (
    <CommonForm label={props.label}>
      <input type="checkbox"
             checked={props.checked}
             onChange={props.onChange} />
    </CommonForm>
  );
};

export default Checkbox;
