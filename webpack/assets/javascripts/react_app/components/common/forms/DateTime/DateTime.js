import React, { Fragment } from 'react';
import PropTypes from 'prop-types';
import { FieldLevelHelp } from 'patternfly-react';
import DateTimePicker from '../../DateTimePicker/DateTimePicker';

import Form from '../CommonForm';
import { documentLocale } from '../../../../common/I18n';
import './DateTimeOverrides.scss';

const DateTime = ({
  label,
  id,
  info,
  isRequired,
  hideValue,
  locale,
  inputProps,
  value,
  initialError,
}) => {
  const currentLocale = locale || documentLocale();

  return (
    <Form
      label={label}
      touched
      error={initialError}
      required={isRequired}
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
        hiddenValue={hideValue && !isRequired}
        value={value}
        id={`template-date-input-${id}`}
        inputProps={{
          autoComplete: 'off',
          ...inputProps,
        }}
        locale={currentLocale}
      />
    </Form>
  );
};

DateTime.propTypes = {
  label: PropTypes.string.isRequired,
  info: PropTypes.string,
  isRequired: PropTypes.bool,
  id: PropTypes.number.isRequired,
  locale: PropTypes.string,
  inputProps: PropTypes.object,
  value: PropTypes.oneOfType([PropTypes.instanceOf(Date), PropTypes.string]),
  initialError: PropTypes.string,
  hideValue: PropTypes.bool,
};

DateTime.defaultProps = {
  info: undefined,
  isRequired: false,
  locale: null,
  value: new Date(),
  initialError: undefined,
  hideValue: false,
  inputProps: {},
};

export default DateTime;
