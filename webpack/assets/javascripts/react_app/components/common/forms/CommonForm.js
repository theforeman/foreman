import React from 'react';

const CommonForm = ({
  className = '',
  label = '',
  touched = false,
  error = undefined,
  required = false,
  children,
}) => {
  if (touched && error) {
    className += 'has-error';
  }

  return (
    <div className={`form-group ${className}`}>
      <label className="col-md-2 control-label">
        {label}
        {required && ' *'}
      </label>
      <div className="col-md-4">{children}</div>
      {touched && error ? (
        <span className="help-block help-inline">
          <span className="error-message">{error}</span>
        </span>
      ) : null}
    </div>
  );
};

export default CommonForm;
