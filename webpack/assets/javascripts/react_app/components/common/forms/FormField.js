import React, { useState } from 'react';
import PropTypes from 'prop-types';
import classNames from 'classnames';
import {
  Col,
  FormGroup,
  ControlLabel,
  HelpBlock,
  FieldLevelHelp,
} from 'patternfly-react';
import { WarningTriangleIcon, ErrorCircleOIcon } from '@patternfly/react-icons';
import InputFactory from './InputFactory';
import { noop } from '../../../common/helpers';

const InlineMessage = ({ error, warning, helpInline }) => {
  if (!error && !warning && !helpInline) {
    return null;
  }
  return (
    <HelpBlock
      className={classNames('help-inline', {
        'error-message': !!error,
        'warning-message': !!warning,
      })}
    >
      {error && <ErrorCircleOIcon className="error-icon" />}
      {!error && warning && <WarningTriangleIcon className="warning-icon" />}
      {error || warning || helpInline}
    </HelpBlock>
  );
};
InlineMessage.propTypes = {
  error: PropTypes.string,
  warning: PropTypes.string,
  helpInline: PropTypes.string,
};
InlineMessage.defaultProps = {
  error: null,
  warning: null,
  helpInline: null,
};

const FormField = ({
  type,
  id,
  name,
  className,
  disabled,
  required,
  error,
  value,
  label,
  labelHelp,
  helpInline,
  labelSizeClass,
  inputSizeClass,
  onChange,
  children,
  inputProps,
  ...otherProps
}) => {
  const [innerError, setError] = useState(error);
  const [innerWarning, setWarning] = useState(null);

  const controlProps = {
    value,
    name,
    disabled,
    required,
    className,
    onChange,
    setError,
    setWarning,
    ...otherProps,
    ...inputProps,
  };

  let validationState = null;
  if (innerWarning) validationState = 'warning';
  if (innerError) validationState = 'error';

  return (
    <FormGroup
      controlId={id}
      disabled={disabled}
      validationState={validationState}
    >
      <ControlLabel className={labelSizeClass}>
        {label}
        {required ? '*' : null}
        {labelHelp && (
          <FieldLevelHelp
            placement="right"
            buttonClass="field-help"
            content={<React.Fragment>{labelHelp}</React.Fragment>}
          />
        )}
      </ControlLabel>
      <Col className={inputSizeClass}>
        {children || <InputFactory type={type} {...controlProps} />}
      </Col>
      <InlineMessage
        error={innerError}
        warning={innerWarning}
        helpInline={helpInline}
      />
    </FormGroup>
  );
};

FormField.propTypes = {
  type: PropTypes.string,
  id: PropTypes.string,
  name: PropTypes.string,
  value: PropTypes.oneOfType([
    PropTypes.string,
    PropTypes.number,
    PropTypes.instanceOf(Date),
    PropTypes.array,
    PropTypes.bool,
  ]),
  className: PropTypes.string,
  label: PropTypes.string,
  labelHelp: PropTypes.string,
  required: PropTypes.bool,
  disabled: PropTypes.bool,
  error: PropTypes.string,
  helpInline: PropTypes.string,
  inputSizeClass: PropTypes.string,
  labelSizeClass: PropTypes.string,
  onChange: PropTypes.func,
  children: PropTypes.element,
  inputProps: PropTypes.object,
};

FormField.defaultProps = {
  type: 'text',
  id: null,
  name: undefined,
  value: undefined,
  className: '',
  label: '',
  labelHelp: null,
  required: false,
  disabled: false,
  error: null,
  helpInline: null,
  inputSizeClass: 'col-md-4',
  labelSizeClass: 'col-md-2',
  onChange: noop,
  children: null,
  inputProps: null,
};

export default FormField;
