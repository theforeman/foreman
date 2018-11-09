import React from 'react';
import PropTypes from 'prop-types';

const CommonForm = ({
  className,
  label,
  touched,
  error,
  required,
  children,
  inputClassName,
}) => (
  <div
    className={`form-group ${className} ${touched && error ? 'has-error' : ''}`}
  >
    <label className="col-md-2 control-label">
      {label}
      {required && ' *'}
    </label>
    <div className={inputClassName}>{children}</div>
    {touched && error && (
      <span className="help-block help-inline">
        <span className="error-message">{error}</span>
      </span>
    )}
  </div>
);

CommonForm.propTypes = {
  className: PropTypes.string,
  label: PropTypes.string,
  touched: PropTypes.bool,
  error: PropTypes.oneOfType([PropTypes.string, PropTypes.bool]),
  required: PropTypes.oneOfType([PropTypes.string, PropTypes.bool]),
  children: PropTypes.node,
  inputClassName: PropTypes.string,
};

CommonForm.defaultProps = {
  className: '',
  label: '',
  touched: false,
  error: undefined,
  required: false,
  children: null,
  inputClassName: 'col-md-4',
};

export default CommonForm;
