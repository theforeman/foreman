import React from 'react';
import CommonForm from './CommonForm';

const TextInput = (props) => {
  return (
    <CommonForm label={props.label}>
      <input type="text"
        className="form-control"
        value={props.value}
        onChange={props.onChange} />
    </CommonForm>
  );
};

export default TextInput;
