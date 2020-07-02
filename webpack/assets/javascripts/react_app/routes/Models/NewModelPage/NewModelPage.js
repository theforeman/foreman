import React from 'react';

import PageLayout from '../../common/PageLayout/PageLayout';
import ModelForm from '../ModelForm'

const NewModelPage = props => {
  return (
    <PageLayout
      header={__('Hardware Models')}
      searchable={false}
      isLoading={false}
    >
      <ModelForm initialValues={{ name: "", hardwareModel: "", vendorClass: "", info: "" }}/>
    </PageLayout>
  )
}

export default NewModelPage;