import React, { useState } from 'react';
import PropTypes from 'prop-types';

import ModelsTable from '../../../../components/ModelsTable';
import Pagination from '../../../../components/Pagination/PaginationWrapper';

import ModelDeleteModal from './ModelDeleteModal';
import LoadingPage from '../../../common/LoadingPage';
import { withRenderHandler } from '../../../../common/HOC';

const ModelsPageContent = ({
  models,
  search,
  sort,
  fetchAndPush,
  itemCount,
  page,
  perPage,
}) => {
  const [toDelete, setToDelete] = useState({});

  return (
    <React.Fragment>
      <ModelDeleteModal toDelete={toDelete} fetchAndPush={fetchAndPush} />
      <ModelsTable
        results={models}
        search={search}
        sortBy={sort.by}
        sortOrder={sort.order}
        getTableItems={fetchAndPush}
        setToDelete={setToDelete}
        id="models-table"
      />
      <Pagination
        viewType="list"
        itemCount={itemCount}
        pagination={{ page, perPage }}
        onChange={fetchAndPush}
        dropdownButtonId="models-page-pagination-dropdown"
      />
    </React.Fragment>
  );
};

ModelsPageContent.propTypes = {
  models: PropTypes.array.isRequired,
  search: PropTypes.string,
  sort: PropTypes.object.isRequired,
  fetchAndPush: PropTypes.func.isRequired,
  itemCount: PropTypes.number.isRequired,
  page: PropTypes.number.isRequired,
  perPage: PropTypes.number.isRequired,
};

ModelsPageContent.defaultProps = {
  search: '',
};

export default withRenderHandler({
  Component: ModelsPageContent,
  LoadingComponent: LoadingPage,
});
