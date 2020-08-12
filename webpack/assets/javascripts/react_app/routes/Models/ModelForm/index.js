import React from 'react';
import { useDispatch } from 'react-redux';
import ModelForm from './ModelForm';

import { submitForm } from '../../../redux/actions/common/forms';

import { MODELS_PATH } from '../constants';
import history from '../../../history';

const WrappedModelForm = props => {
  const dispatch = useDispatch();

  const dispatchSubmit = params => dispatch(submitForm(params));

  const toModelsPage = () => history.push({ pathname: MODELS_PATH });

  const onSubmit = async (values, actions) => {
    const submitParams = {
      url: props.url,
      values,
      item: 'Models',
      message: props.message
    };
    await dispatchSubmit(submitParams);
    toModelsPage();
  }

  return (
    <ModelForm {...props} onSubmit={onSubmit} onCancel={toModelsPage} />
  )
}

export default WrappedModelForm;
