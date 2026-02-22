import React, { useEffect } from 'react';
import PropTypes from 'prop-types';
import { Field } from 'formik';

import CommonForm from '../CommonForm';
import RadioButton from './RadioButton';
import { deprecate } from '../../../../common/DeprecationService';

const RadioButtonGroup = ({
  controlLabel,
  radios,
  name,
  className,
  inputClassName,
  disabled,
}) => {
  useEffect(() => {
    deprecate(
      'forms/RadioButtonGroup',
      'Radio from @patternfly/react-core',
      '3.21'
    );
  }, []);

  return (
    <CommonForm
      label={controlLabel}
      className={className}
      inputClassName={inputClassName}
    >
      {radios.map((item, index) => (
        <Field
          key={index}
          name={name}
          render={({ field }) => (
            <RadioButton
              input={field}
              disabled={disabled}
              item={item}
              name={name}
              checked={field.value === item.value}
            />
          )}
        />
      ))}
    </CommonForm>
  );
};

RadioButtonGroup.propTypes = {
  controlLabel: PropTypes.string.isRequired,
  name: PropTypes.string.isRequired,
  className: PropTypes.string,
  inputClassName: PropTypes.string,
  disabled: PropTypes.bool,
  radios: PropTypes.arrayOf(
    PropTypes.shape({
      value: PropTypes.string,
      label: PropTypes.string,
      checked: PropTypes.bool,
    })
  ),
};

RadioButtonGroup.defaultProps = {
  radios: [],
  className: '',
  inputClassName: 'col-md-6',
  disabled: false,
};

export default RadioButtonGroup;
