import React from 'react';
import PropTypes from 'prop-types';
import PageLayout from '../common/PageLayout/PageLayout';
import { translate as __, sprintf } from '../../common/I18n';
import { useAPI } from '../../common/hooks/API/APIHooks';
import { FiltersForm } from './FiltersForm';

const EditFiltersFormPage = ({
  match: {
    params: { id },
  },
  history,
}) => {
  const { response } = useAPI('get', `/api/filters/${id}`);
  const roleName = response?.role?.name || '';
  const roleId = response?.role?.id || '';
  const breadcrumbOptions = {
    breadcrumbItems: [
      { caption: __('Roles'), url: '/roles' },
      {
        caption: roleName,
        url: `/filters?role_id=${roleId}`,
      },
      {
        caption: sprintf(
          __('Edit %s Resource Filter'),
          response.resource_type_label
        ),
      },
    ],
    isSwitchable: true,
    resource: {
      resourceUrl: '/api/v2/filters',
      resourceFilter: `role_id=${roleId}`,
      nameField: 'resource_type_label',
      switcherItemUrl: '/filters/:id/edit',
    },
  };

  return (
    <PageLayout
      header={__('Filter')}
      searchable={false}
      breadcrumbOptions={breadcrumbOptions}
    >
      {roleName.length ? (
        <FiltersForm
          isNew={false}
          roleName={roleName}
          roleId={roleId}
          data={response}
          history={history}
        />
      ) : (
        <div />
      )}
    </PageLayout>
  );
};

EditFiltersFormPage.propTypes = {
  location: PropTypes.shape({
    search: PropTypes.string.isRequired,
  }).isRequired,
  match: PropTypes.shape({
    params: PropTypes.shape({
      id: PropTypes.string.isRequired,
    }).isRequired,
  }).isRequired,
  history: PropTypes.object.isRequired,
};

export default EditFiltersFormPage;
