import React from 'react';

import { translate as __ } from '../../../common/I18n';
import TableIndexPage from '../../../components/PF4/TableIndexPage/TableIndexPage';
import { MODELS_API_PATH, API_REQUEST_KEY } from '../constants';

const ModelsPage = () => {
  const columns = {
    name: {
      title: __('Name'),
      wrapper: ({ can_edit: canEdit, id, name }) =>
        canEdit ? (
          <a href={`/models/${id}/edit`}>{name}</a>
        ) : (
          <span>{name}</span>
        ),
      isSorted: true,
    },
    vendor_class: {
      title: __('Vendor class'),
    },
    hardware_model: {
      title: __('Hardware model'),
    },
    hosts_count: {
      title: __('Hosts'),
    },
  };
  return (
    <TableIndexPage
      apiUrl={MODELS_API_PATH}
      apiOptions={{ key: API_REQUEST_KEY }}
      header={__('Hardware models')}
      controller="models"
      isDeleteable
      columns={columns}
    />
  );
};

export default ModelsPage;
