import React, { useState } from 'react';
import PropTypes from 'prop-types';

import ModelsTable from '../../../../components/ModelsTable';
import Pagination from '../../../../components/Pagination';

import ModelDeleteModal from './ModelDeleteModal';
import LoadingPage from '../../../common/LoadingPage';
import { withRenderHandler } from '../../../../common/HOC';

const ModelsPageContent = ({ models, sort, fetchAndPush, itemCount }) => {
  const [toDelete, setToDelete] = useState({});

  return (
    <React.Fragment>
      <ModelDeleteModal toDelete={toDelete} fetchAndPush={fetchAndPush} />
      <ModelsTable
        results={models}
        sortBy={sort.by}
        sortOrder={sort.order}
        getTableItems={fetchAndPush}
        setToDelete={setToDelete}
        id="models-table"
      />
      <Pagination itemCount={itemCount} onChange={fetchAndPush} noSidePadding />
    </React.Fragment>
  );
};

ModelsPageContent.propTypes = {
  models: PropTypes.array.isRequired,
  sort: PropTypes.object.isRequired,
  fetchAndPush: PropTypes.func.isRequired,
  itemCount: PropTypes.number.isRequired,
};

export default withRenderHandler({
  Component: ModelsPageContent,
  LoadingComponent: LoadingPage,
});
