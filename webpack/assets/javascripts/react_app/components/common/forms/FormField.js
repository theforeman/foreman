import React, { useEffect, useState } from 'react';
import PropTypes from 'prop-types';
import classNames from 'classnames';
import {
  FormHelperText,
  HelperText,
  HelperTextItem,
  Icon,
} from '@patternfly/react-core';
import {
  ExclamationCircleIcon,
  ExclamationTriangleIcon,
} from '@patternfly/react-icons';
import InputFactory from './InputFactory';
import LabelIcon from '../LabelIcon';
import { noop } from '../../../common/helpers';

const InlineMessage = ({ error, warning, helpInline }) => {
  // eslint-disable-next-line no-nested-ternary
  const variant = error ? 'error' : warning ? 'warning' : 'default';
  const message = error || warning || helpInline;

  if (!message) return null;

  return (
    <FormHelperText>
      <HelperText>
        <HelperTextItem
          variant={variant}
          icon={
            (error || warning) && (
              <Icon>
                {error ? (
                  <ExclamationCircleIcon />
                ) : (
                  <ExclamationTriangleIcon />
                )}
              </Icon>
            )
          }
        >
          {message}
        </HelperTextItem>
      </HelperText>
    </FormHelperText>
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

  useEffect(() => {
    setError(error);
  }, [error]);

  let validated;
  if (innerWarning) validated = 'warning';
  if (innerError) validated = 'error';

  const controlProps = {
    id,
    value,
    name,
    disabled,
    required,
    className,
    onChange,
    setError,
    setWarning,
    validated,
    ...otherProps,
    ...inputProps,
  };

  return (
    <div
      className={classNames('form-group', {
        'has-error': innerError,
        'has-warning': innerWarning && !innerError,
      })}
    >
      <label
        htmlFor={id}
        className={classNames('control-label', labelSizeClass)}
      >
        {label}
        {required ? '*' : null}
        {'  '}
        {labelHelp && <LabelIcon text={labelHelp} />}
      </label>
      <div className={inputSizeClass}>
        {children || <InputFactory type={type} {...controlProps} />}
      </div>
      <InlineMessage
        error={innerError}
        warning={innerWarning}
        helpInline={helpInline}
      />
    </div>
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
