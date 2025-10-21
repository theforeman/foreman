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
import {
  FormGroup as PF5FormGroup,
  FormHelperText,
  HelperText,
  HelperTextItem,
  Icon,
} from '@patternfly/react-core';

import LabelIcon from 'foremanReact/components/common/LabelIcon';
import { WarningTriangleIcon, ErrorCircleOIcon } from '@patternfly/react-icons';
import InputFactory from './InputFactory';
import { noop } from '../../../common/helpers';

const InlineMessagePF5 = ({ error, warning, helpInline }) => {
  if (!error && !warning && !helpInline) {
    return null;
  }
  const validationState = Object.entries({ error, warning }).find(
    ([_, v]) => v
  )?.[0];
  const icon = () =>
    ({
      error: { icon: <ErrorCircleOIcon /> },
      warning: { icon: <WarningTriangleIcon /> },
    }[validationState]);

  return (
    <FormHelperText>
      <HelperText>
        <HelperTextItem variant={validationState || 'default'} {...icon()}>
          {error || warning || helpInline}
        </HelperTextItem>
      </HelperText>
    </FormHelperText>
  );
};
InlineMessagePF5.propTypes = {
  error: PropTypes.string,
  warning: PropTypes.string,
  helpInline: PropTypes.string,
};
InlineMessagePF5.defaultProps = {
  error: null,
  warning: null,
  helpInline: null,
};

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
      {error && (
        <Icon className="error-icon">
          <ErrorCircleOIcon />
        </Icon>
      )}
      {!error && warning && (
        <Icon className="warning-icon">
          <WarningTriangleIcon />
        </Icon>
      )}
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
  isPF5,
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

  if (isPF5) {
    return (
      <PF5FormGroup
        role="group"
        fieldId={id}
        label={label}
        labelIcon={
          typeof labelHelp === 'string' ? <LabelIcon text={labelHelp} /> : null
        }
        isRequired={required}
        isStack
        disabled={disabled}
      >
        {children}
        <InlineMessagePF5
          error={innerError}
          warning={innerWarning}
          helpInline={helpInline}
        />
      </PF5FormGroup>
    );
  }
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

PF5FormGroup.propTypes = {
  fieldId: PropTypes.string,
  label: PropTypes.string,
  labelIcon: PropTypes.element,
  isRequired: PropTypes.bool,
  isDisabled: PropTypes.bool,
  validationState: PropTypes.oneOf([null, 'error', 'warning', 'success']),
  isStack: PropTypes.bool,
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
  labelHelp: PropTypes.oneOfType([PropTypes.string, PropTypes.element]),
  required: PropTypes.bool,
  disabled: PropTypes.bool,
  error: PropTypes.string,
  helpInline: PropTypes.string,
  inputSizeClass: PropTypes.string,
  labelSizeClass: PropTypes.string,
  onChange: PropTypes.func,
  children: PropTypes.element,
  inputProps: PropTypes.object,
  isPF5: PropTypes.bool,
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
  isPF5: false,
};

export default FormField;
