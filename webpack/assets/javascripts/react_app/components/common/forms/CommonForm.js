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
  tooltipHelp,
  labelClass,
}) => (
  <div
    className={`form-group ${className} ${touched && error ? 'has-error' : ''}`}
  >
    <label className={`${labelClass} control-label`}>
      {label}
      {required && ' *'}
      {tooltipHelp}
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
  tooltipHelp: PropTypes.node,
  labelClass: PropTypes.string,
};

CommonForm.defaultProps = {
  className: '',
  label: '',
  touched: false,
  error: undefined,
  required: false,
  children: null,
  inputClassName: 'col-md-4',
  tooltipHelp: null,
  labelClass:  'col-md-2'
};

export default CommonForm;
