import React from 'react';
import { translate as __ } from '../../../common/I18n';

import ForemanForm from '../../../components/common/forms/ForemanForm';
import TextField from '../../../components/common/forms/TextField';

const ModelForm = props => {
  return (
    <ForemanForm
      onSubmit={(values, actions) => {}}
      initialValues={props.initialValues}
      onCancel={() => {}}
    >
      <TextField name="name" type="text" required="true" label={__('Name')} />
      <TextField name="hardwareModel" type="text" label={__('Hardware Model')} />
      <TextField name="vendorClass" type="text" label={__('Vendor Class')} />
      <TextField name="info" type="textarea" label={__('Information')} />
    </ForemanForm>
  )
}

export default ModelForm;
