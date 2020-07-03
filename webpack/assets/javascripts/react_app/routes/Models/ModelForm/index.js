import React from 'react';
import ModelForm from './ModelForm';

import { submitForm } from '../../../redux/actions/common/forms';

import { MODELS_PATH } from '../constants';

const WrappedModelForm = props => {
  const onSubmit = async (values, actions) => {
    const submitParams = {
      url: props.url,
      values,
      item: 'Models',
      message: props.message
    };
    const res = await submitForm(submitParams);
    console.log(res);
  }

  onCancel = (history) => history.push({ pathname: MODELS_PATH });

  return (
    <ModelForm {...props} onSubmit={onSubmit} onCancel={onCancel} />
  )
}

export default WrappedModelForm;
