import React from 'react';
import PropTypes from 'prop-types';

import { useDispatch } from 'react-redux';
import { submitForm } from '../../../../../redux/actions/common/forms';
import SettingForm from './SettingForm';

const WrappedSettingForm = props => {
  const dispatch = useDispatch();

  return (
    <SettingForm
      submitForm={(...args) => dispatch(submitForm(...args))}
      initialValues={{ value: props.setting.value }}
      {...props}
    />
  );
};

WrappedSettingForm.propTypes = {
  setting: PropTypes.object.isRequired,
};

export default WrappedSettingForm;
