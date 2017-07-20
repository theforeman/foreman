import React from 'react';

const CommonForm = ({ className = '', label = '', children }) => {
  return (
    <div className={`form-group ${className}`}>
      <label className="col-md-2 control-label">
        {label}
      </label>
      <div className="col-md-4">
        {children}
      </div>
    </div>
  );
};

export default CommonForm;
