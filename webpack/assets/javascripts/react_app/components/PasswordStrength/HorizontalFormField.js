import React from 'react';
import PropTypes from 'prop-types';

const HorizontalFormField = ({
  label,
  required,
  touched,
  error,
  children,
  inputClassName,
}) => (
  <div className={`form-group ${touched && error ? 'has-error' : ''}`}>
    <label className="col-md-2 control-label">
      {label}
      {required ? ' *' : null}
    </label>
    <div className={inputClassName}>{children}</div>
    {touched && error && (
      <span className="help-block help-inline">
        <span className="error-message">{error}</span>
      </span>
    )}
  </div>
);

HorizontalFormField.propTypes = {
  label: PropTypes.string.isRequired,
  required: PropTypes.bool,
  touched: PropTypes.bool,
  error: PropTypes.oneOfType([PropTypes.string, PropTypes.bool]),
  children: PropTypes.node.isRequired,
  inputClassName: PropTypes.string,
};

HorizontalFormField.defaultProps = {
  required: false,
  touched: false,
  error: undefined,
  inputClassName: 'col-md-4',
};

export default HorizontalFormField;
