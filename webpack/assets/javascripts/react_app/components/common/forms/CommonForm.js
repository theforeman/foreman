import React from 'react';

const CommonForm = (props) => {
  return (
    <div className="clearfix">
      <div className="form-group">
        <label className="col-md-2">{props.label}</label>
        <div className="col-md-4">
          {props.children}
        </div>
      </div>
    </div>
  );
};

export default CommonForm;
