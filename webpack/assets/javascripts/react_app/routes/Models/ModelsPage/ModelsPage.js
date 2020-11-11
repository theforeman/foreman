import React from 'react';
import PropTypes from 'prop-types';
import { Button } from 'patternfly-react';
import { Link } from 'react-router-dom';

import { translate as __ } from '../../../common/I18n';
import PageLayout from '../../common/PageLayout/PageLayout';
import ModelsPageContent from './components/ModelsPageContent';
import { MODELS_SEARCH_PROPS } from '../constants';

const ModelsPage = ({
  fetchAndPush,
  search,
  isLoading,
  hasData,
  models,
  page,
  perPage,
  sort,
  hasError,
  itemCount,
  message,
  canCreate,
  toasts,
}) => {
  const handleSearch = query => fetchAndPush({ searchQuery: query, page: 1 });

  const createBtn = (
    <Link to="/models/new">
      <Button bsStyle="primary">{__('Create Model')}</Button>
    </Link>
  );

  return (
    <PageLayout
      header={__('Hardware Models')}
      searchable
      searchProps={MODELS_SEARCH_PROPS}
      searchQuery={search}
      isLoading={isLoading && hasData}
      onSearch={handleSearch}
      onBookmarkClick={handleSearch}
      toolbarButtons={canCreate && createBtn}
      toastNotifications={toasts}
    >
      <ModelsPageContent
        models={models}
        page={page}
        perPage={perPage}
        search={search}
        sort={sort}
        hasData={hasData}
        hasError={hasError}
        isLoading={isLoading}
        itemCount={itemCount}
        fetchAndPush={fetchAndPush}
        message={message}
      />
    </PageLayout>
  );
};

ModelsPage.propTypes = {
  fetchAndPush: PropTypes.func.isRequired,
  search: PropTypes.string,
  isLoading: PropTypes.bool.isRequired,
  hasData: PropTypes.bool.isRequired,
  models: PropTypes.array.isRequired,
  page: PropTypes.number,
  perPage: PropTypes.number,
  sort: PropTypes.object.isRequired,
  hasError: PropTypes.bool.isRequired,
  itemCount: PropTypes.number.isRequired,
  message: PropTypes.object,
  canCreate: PropTypes.bool.isRequired,
  toasts: PropTypes.array.isRequired,
};

ModelsPage.defaultProps = {
  page: null,
  perPage: null,
  search: '',
  message: {},
};

export default ModelsPage;
