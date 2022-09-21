import React from 'react';
import PropTypes from 'prop-types';
import URI from 'urijs';
import PageLayout from '../common/PageLayout/PageLayout';
import { translate as __ } from '../../common/I18n';
import { useAPI } from '../../common/hooks/API/APIHooks';
import { FiltersForm } from './FiltersForm';

const NewFiltersFormPage = ({ location: { search }, history }) => {
  const { role_id: urlRoleId } = URI.parseQuery(search);
  const {
    response: { name: roleName, id: roleId },
  } = useAPI('get', `/api/v2/roles/${urlRoleId}`);
  const breadcrumbOptions = {
    breadcrumbItems: [
      { caption: __('Roles'), url: '/roles' },
      { caption: roleName, url: `/filters?role_id=${roleId}` },
      { caption: __('Create Filter') },
    ],
  };
  return (
    <PageLayout
      header={__('Filter')}
      searchable={false}
      breadcrumbOptions={breadcrumbOptions}
    >
      {roleName ? (
        <FiltersForm
          isNew
          roleName={roleName || ''}
          roleId={urlRoleId}
          data={{}}
          history={history}
        />
      ) : (
        <div />
      )}
    </PageLayout>
  );
};

NewFiltersFormPage.propTypes = {
  location: PropTypes.shape({
    search: PropTypes.string.isRequired,
  }).isRequired,
  history: PropTypes.object.isRequired,
};

export default NewFiltersFormPage;
