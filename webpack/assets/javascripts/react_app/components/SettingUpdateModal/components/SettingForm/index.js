import React from 'react';
import PropTypes from 'prop-types';

import { useDispatch } from 'react-redux';
import { submitForm } from '../../../../redux/actions/common/forms';
import SettingForm from './SettingForm';

const initialValue = setting => {
  if (setting.encrypted) {
    return '';
  }

  return setting.value === null ? '' : setting.value;
};

const WrappedSettingForm = props => {
  const dispatch = useDispatch();

  return (
    <SettingForm
      submitForm={(...args) => dispatch(submitForm(...args))}
      initialValues={{
        value: initialValue(props.setting),
      }}
      {...props}
    />
  );
};

WrappedSettingForm.propTypes = {
  setting: PropTypes.object.isRequired,
};

export default WrappedSettingForm;
