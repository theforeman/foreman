import React from 'react';

import { translate as __ } from '../../../common/I18n';
import PageLayout from '../../common/PageLayout/PageLayout';
import ModelForm from '../ModelForm';

import { CREATE_MODEL_API_PATH, MODELS_PATH } from '../constants';

const NewModelPage = props => {
  const title = __('Hardware Models');

  const breadcrumbOptions = {
    breadcrumbItems: [
      { caption: title, url: MODELS_PATH },
      { caption: __('Create Hardware Model') },
    ],
    switchable: false,
  };

  return (
    <PageLayout
      header={title}
      breadcrumbOptions={breadcrumbOptions}
      searchable={false}
      isLoading={false}
    >
      <ModelForm initialValues={{ name: "", hardwareModel: "", vendorClass: "", info: "" }} url={CREATE_MODEL_API_PATH} message={__('Hardware Model successfully created.')} />
    </PageLayout>
  )
}

export default NewModelPage;
