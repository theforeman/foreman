import React, { useEffect } from 'react';
import PropTypes from 'prop-types';
import { deprecate } from '../../../common/DeprecationService';

const CommonForm = ({
  className,
  label,
  touched,
  error,
  required,
  children,
  inputClassName,
  tooltipHelp,
}) => {
  useEffect(() => {
    deprecate('forms/CommonForm', 'Form from @patternfly/react-core', '3.21');
  }, []);

  return (
    <div
      className={`form-group ${className} ${
        touched && error ? 'has-error' : ''
      }`}
    >
      <label className="col-md-2 control-label">
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
};

CommonForm.propTypes = {
  className: PropTypes.string,
  label: PropTypes.string,
  touched: PropTypes.bool,
  error: PropTypes.oneOfType([PropTypes.string, PropTypes.bool]),
  required: PropTypes.oneOfType([PropTypes.string, PropTypes.bool]),
  children: PropTypes.node,
  inputClassName: PropTypes.string,
  tooltipHelp: PropTypes.node,
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
};

export default CommonForm;
