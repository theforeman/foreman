import React, { useEffect, useState } from 'react';
import PropTypes from 'prop-types';
import { useDispatch, useSelector, shallowEqual } from 'react-redux';
import { useHistory } from 'react-router-dom';
import PageLayout from '../common/PageLayout/PageLayout';
import { translate as __, sprintf } from '../../common/I18n';
import { submitForm } from '../../redux/actions/common/forms';
import { STATUS } from '../../constants';
import { APIActions } from '../../redux/API';
import {
  selectAPIErrorMessage,
  selectAPIHttpStatus,
  selectAPIResponse,
  selectAPIStatus,
} from '../../redux/API/APISelectors';
import { MODELS_API_PATH, MODELS_PATH } from './constants';
import { modelErrorToast } from './modelErrorToast';

import ModelForm from './ModelForm';
import ModelFormSkeleton from './ModelFormSkeleton';
import ModelFormEmptyState from './ModelFormEmptyState';

const modelToInitialValues = data => ({
  name: data.name,
  hardware_model: data.hardware_model || '',
  vendor_class: data.vendor_class || '',
  info: data.info || '',
});

const EditModelFormPage = ({
  match: {
    params: { id },
  },
}) => {
  const dispatch = useDispatch();
  const history = useHistory();
  const fetchKey = `MODEL_EDIT_${id}`;
  const status = useSelector(state => selectAPIStatus(state, fetchKey));
  const apiResponse = useSelector(
    state => selectAPIResponse(state, fetchKey),
    shallowEqual
  );
  const initialValues =
    status === STATUS.RESOLVED &&
    apiResponse &&
    typeof apiResponse.id !== 'undefined'
      ? modelToInitialValues(apiResponse)
      : null;
  const errorMessage = useSelector(state =>
    selectAPIErrorMessage(state, fetchKey)
  );
  const httpStatus = useSelector(state => selectAPIHttpStatus(state, fetchKey));
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    dispatch(
      APIActions.get({
        url: `${MODELS_API_PATH}/${id}`,
        key: fetchKey,
      })
    );
  }, [dispatch, id, fetchKey]);

  const handleSubmit = formValues => {
    setIsSubmitting(true);
    dispatch(
      submitForm({
        item: 'Model',
        method: 'put',
        url: `${MODELS_API_PATH}/${id}`,
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

  const breadcrumbOptions = {
    breadcrumbItems: [
      {
        caption: __('Hardware Models'),
        url: MODELS_PATH,
        onClick: e => {
          e.preventDefault();
          history.push(MODELS_PATH);
        },
      },
      {
        caption: initialValues
          ? sprintf(__('Edit %s'), initialValues.name || '')
          : __('Edit'),
      },
    ],
    isSwitchable: true,
    resource: {
      resourceUrl: MODELS_API_PATH,
      nameField: 'name',
      switcherItemUrl: `${MODELS_PATH}/:id/edit`,
    },
    onSwitcherItemClick: (e, href) => {
      e.preventDefault();
      history.push(href);
    },
  };

  const isLoading = status !== STATUS.ERROR && initialValues === null;

  let pageContent;
  if (status === STATUS.ERROR) {
    pageContent = (
      <ModelFormEmptyState
        modelId={id}
        errorMessage={errorMessage}
        httpStatus={httpStatus}
      />
    );
  } else if (isLoading) {
    pageContent = <ModelFormSkeleton />;
  } else {
    pageContent = (
      <ModelForm
        key={id}
        initialValues={initialValues}
        handleSubmit={handleSubmit}
        isSubmitting={isSubmitting}
      />
    );
  }

  return (
    <PageLayout searchable={false} breadcrumbOptions={breadcrumbOptions}>
      {pageContent}
    </PageLayout>
  );
};

EditModelFormPage.propTypes = {
  match: PropTypes.shape({
    params: PropTypes.shape({
      id: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
    }).isRequired,
  }).isRequired,
};

export default EditModelFormPage;
