import React from 'react';
import PropTypes from 'prop-types';
import { Field as FormikField } from 'formik';

import ForemanForm from '../../../../../components/common/forms/ForemanForm';
import SettingValueField from './SettingValueField';
import { SETTING_UPDATE_PATH } from '../../../constants';

import { translate as __ } from '../../../../../common/I18n';

const SettingForm = props => {
  const handleSubmit = async (values, actions) => {
    let submitValues = { setting: values };

    if (props.setting && props.setting.settingsType === 'array') {
      const splitValue = { value: values.value.split(',') };
      submitValues = { setting: splitValue };
    }

    await props.submitForm({
      url: SETTING_UPDATE_PATH.replace(':id', props.setting.id),
      values: submitValues,
      item: 'Settings',
      message: __('Setting was successfully updated.'),
      method: 'put',
    });
    props.setModalClosed();
  };

  return (
    <ForemanForm
      onSubmit={(values, actions) => handleSubmit(values, actions)}
      initialValues={props.initialValues}
      onCancel={props.setModalClosed}
    >
      <FormikField
        name="value"
        component={SettingValueField}
        setting={props.setting}
      />
    </ForemanForm>
  );
};

SettingForm.propTypes = {
  setting: PropTypes.object.isRequired,
  initialValues: PropTypes.object.isRequired,
  setModalClosed: PropTypes.func.isRequired,
  submitForm: PropTypes.func.isRequired,
};

export default SettingForm;
