import React, { Fragment } from 'react';
import PropTypes from 'prop-types';
import { FieldLevelHelp } from 'patternfly-react';
import { Field } from 'formik';
import DateTimePicker from '../../DateTimePicker/DateTimePicker';

import CommonForm from '../CommonForm';
import { documentLocale } from '../../../../common/I18n';
import './DateTimeOverrides.scss';

const DateTime = ({
  label,
  id,
  info,
  isRequired,
  locale,
  inputProps: { name },
  inputProps,
  value,
  initialError,
}) => {
  const currentLocale = locale || documentLocale();

  return (
    <Field
      name={name}
      render={({ form: { setFieldValue, errors = {} } }) => (
        <CommonForm
          label={label}
          touched
          error={errors[name] || initialError}
          required={isRequired}
          inputClassName="col-md-6"
          tooltipHelp={
            info && (
              <FieldLevelHelp
                buttonClass="field-help"
                content={<Fragment>{info}</Fragment>}
              />
            )
          }
        >
          <DateTimePicker
            value={value}
            id={`template-date-input-${id}`}
            inputProps={{
              autoComplete: 'off',
              ...inputProps,
            }}
            locale={currentLocale}
            name={name}
            placement="bottom"
            required={isRequired}
            onChange={(newValue) => setFieldValue(name, newValue)}
          />
        </CommonForm>
      )}
    />
  );
};

DateTime.propTypes = {
  label: PropTypes.string.isRequired,
  info: PropTypes.string,
  isRequired: PropTypes.bool,
  id: PropTypes.oneOfType([PropTypes.number, PropTypes.string]).isRequired,
  locale: PropTypes.string,
  inputProps: PropTypes.object,
  value: PropTypes.oneOfType([PropTypes.instanceOf(Date), PropTypes.string]),
  initialError: PropTypes.string,
};

DateTime.defaultProps = {
  info: undefined,
  isRequired: false,
  locale: null,
  value: new Date(),
  initialError: undefined,
  inputProps: {},
};

export default DateTime;
