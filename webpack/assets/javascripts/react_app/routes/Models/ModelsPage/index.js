import React from 'react';
import { useHistory, Link } from 'react-router-dom';

import { translate as __ } from '../../../common/I18n';
import TableIndexPage from '../../../components/PF4/TableIndexPage/TableIndexPage';
import {
  MODELS_API_PATH,
  MODELS_PATH_NEW,
  API_REQUEST_KEY,
} from '../constants';

const ModelsPage = () => {
  const history = useHistory();
  const columns = {
    name: {
      title: __('Name'),
      wrapper: ({ can_edit: canEdit, id, name }) =>
        canEdit ? (
          <Link to={`/models/${id}/edit`}>{name}</Link>
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
      customCreateAction={() => () => history.push(MODELS_PATH_NEW)}
      columns={columns}
    />
  );
};

export default ModelsPage;
