import React, { useContext } from 'react';
import PropTypes from 'prop-types';
import classNames from 'classnames';
import { pick, omit, keys } from 'lodash';
import {
  Col,
  FormGroup,
  FormControl,
  ControlLabel,
  HelpBlock,
  FieldLevelHelp,
} from 'patternfly-react';

import { noop } from '../../../common/helpers';
import DateTimePicker from '../DateTimePicker/DateTimePicker';
import DatePicker from '../DateTimePicker/DatePicker';
import TimePicker from '../DateTimePicker/TimePicker';

const inputComponents = {
  date: DatePicker,
  dateTime: DateTimePicker,
  time: TimePicker,
};

export const registerInputComponent = (name, Component) => {
  inputComponents[name] = Component;
};

export const wrapInput = (type, Input) => {
  registerInputComponent(type, Input);
  const Field = props => (
    <FormField
      {...pick(props, keys(FormField.propTypes))}
      inputProps={omit(props, keys(FormField.propTypes))}
      type={type}
    />
  );
  Field.displayName = `FormField(${Input.displayName ||
    Input.name ||
    'Input'})`;
  return Field;
};

export const ControlContext = React.createContext();

const InputFactory = ({ type }) => {
  const controlProps = useContext(ControlContext);

  if (inputComponents[type]) {
    return (
      <FormControl componentClass={inputComponents[type]} {...controlProps} />
    );
  }
  return <FormControl type={type} {...controlProps} />;
};
InputFactory.propTypes = {
  type: PropTypes.string.isRequired,
};

const InlineMessage = ({ error, helpInline }) => {
  if (!error && !helpInline) {
    return null;
  }
  return (
    <HelpBlock
      className={classNames('help-inline', { 'error-message': !!error })}
    >
      {error || helpInline}
    </HelpBlock>
  );
};
InlineMessage.propTypes = {
  error: PropTypes.string,
  helpInline: PropTypes.string,
};
InlineMessage.defaultProps = {
  error: null,
  helpInline: null,
};

const FormField = ({
  type,
  id,
  name,
  className,
  disabled,
  required,
  touched,
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
}) => {
  const controlProps = {
    value,
    name,
    className,
    onChange,
    ...inputProps,
  };

  return (
    <FormGroup
      controlId={id}
      disabled={disabled}
      validationState={touched && error ? 'error' : null}
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
        <ControlContext.Provider value={controlProps}>
          {children || <InputFactory type={type} />}
        </ControlContext.Provider>
      </Col>
      <InlineMessage error={touched ? error : null} helpInline={helpInline} />
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
  ]),
  className: PropTypes.string,
  label: PropTypes.string,
  labelHelp: PropTypes.string,
  required: PropTypes.bool,
  disabled: PropTypes.bool,
  touched: PropTypes.bool,
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
  touched: false,
  error: undefined,
  helpInline: null,
  inputSizeClass: 'col-md-4',
  labelSizeClass: 'col-md-2',
  onChange: noop,
  children: null,
  inputProps: null,
};

export default FormField;
