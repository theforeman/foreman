import React, { useState } from 'react';
import { useDispatch } from 'react-redux';
import { useHistory } from 'react-router-dom';
import PageLayout from '../common/PageLayout/PageLayout';
import { translate as __ } from '../../common/I18n';
import { submitForm } from '../../redux/actions/common/forms';
import { MODELS_API_PATH, MODELS_PATH } from './constants';
import { modelErrorToast } from './modelErrorToast';

import ModelForm from './ModelForm';

const EMPTY_MODEL_INITIAL_VALUES = {
  name: '',
  hardware_model: '',
  vendor_class: '',
  info: '',
};

const NewModelFormPage = () => {
  const dispatch = useDispatch();
  const history = useHistory();
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = formValues => {
    setIsSubmitting(true);
    dispatch(
      submitForm({
        item: 'Model',
        method: 'post',
        url: MODELS_API_PATH,
        values: { model: formValues },
        actions: {},
        errorToast: modelErrorToast,
        successCallback: () => {
          history.push(MODELS_PATH);
        },
        handleError: () => {
          setIsSubmitting(false);
        },
      })
    );
  };

  return (
    <PageLayout
      searchable={false}
      breadcrumbOptions={{
        breadcrumbItems: [
          {
            caption: __('Hardware Models'),
            url: MODELS_PATH,
            onClick: e => {
              e.preventDefault();
              history.push(MODELS_PATH);
            },
          },
          { caption: __('Create Model') },
        ],
      }}
    >
      <ModelForm
        initialValues={EMPTY_MODEL_INITIAL_VALUES}
        handleSubmit={handleSubmit}
        isSubmitting={isSubmitting}
      />
    </PageLayout>
  );
};

export default NewModelFormPage;
