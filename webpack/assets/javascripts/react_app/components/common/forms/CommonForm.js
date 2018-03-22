import React from 'react';

const CommonForm = ({
  className = '',
  label = '',
  touched = false,
  error = undefined,
  required = false,
  children,
  inputClassName = 'col-md-4',
}) => (
    <div className={`form-group ${className} ${touched && error ? 'has-error' : ''}`}>
      <label className="col-md-2 control-label">
        {label}
        {required && ' *'}
      </label>
      <div className={inputClassName}>{children}</div>
      {touched &&
      error && (
        <span className="help-block help-inline">
          <span className="error-message">{error}</span>
        </span>
      )}
    </div>
);

export default CommonForm;
