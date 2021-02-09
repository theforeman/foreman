import React from 'react';
import PropTypes from 'prop-types';
import { Field as FormikField } from 'formik';
import ForemanForm from '../../../common/forms/ForemanForm';
import SettingValueField from '../SettingValueField';
import { SETTING_UPDATE_PATH } from '../../SettingUpdateModalConstants';

import { translate as __ } from '../../../../common/I18n';

const SettingForm = ({
  setting,
  initialValues,
  setModalClosed,
  submitForm,
}) => {
  const handleSubmit = (values, actions) => {
    let submitValues = { setting: values };

    if (setting && setting.settingsType === 'array') {
      const splitValue = values.value === '' ? [] : values.value.split(',');
      submitValues = { setting: { value: splitValue } };
    }

    return submitForm({
      url: SETTING_UPDATE_PATH.replace(':id', setting.id),
      values: submitValues,
      item: 'Settings',
      message: __('Setting was successfully updated.'),
      method: 'put',
      successCallback: setModalClosed,
      actions,
    });
  };

  return (
    <ForemanForm
      onSubmit={handleSubmit}
      initialValues={initialValues}
      onCancel={setModalClosed}
    >
      <FormikField
        name="value"
        label={__('Value')}
        component={SettingValueField}
        setting={setting}
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
