import React from 'react';
import PropTypes from 'prop-types';

import { translate as __ } from '../../../common/I18n';
import TableIndexPage from '../../../components/PF4/TableIndexPage/TableIndexPage';
import ModelsPageContent from './components/ModelsPageContent';
import { MODELS_API_PATH, API_REQUEST_KEY } from '../constants';

const ModelsPage = ({
  fetchAndPush,
  isLoading,
  hasData,
  models,
  sort,
  hasError,
  itemCount,
  message,
}) => (
  <TableIndexPage
    apiUrl={MODELS_API_PATH}
    apiOptions={{ key: API_REQUEST_KEY }}
    header={__('Hardware models')}
    controller="models"
  >
    <ModelsPageContent
      models={models}
      sort={sort}
      hasData={hasData}
      hasError={hasError}
      isLoading={isLoading}
      itemCount={itemCount}
      fetchAndPush={fetchAndPush}
      message={message}
    />
  </TableIndexPage>
);

ModelsPage.propTypes = {
  fetchAndPush: PropTypes.func.isRequired,
  isLoading: PropTypes.bool.isRequired,
  hasData: PropTypes.bool.isRequired,
  models: PropTypes.array.isRequired,
  sort: PropTypes.object.isRequired,
  hasError: PropTypes.bool.isRequired,
  itemCount: PropTypes.number.isRequired,
  message: PropTypes.object,
};

ModelsPage.defaultProps = {
  message: {},
};

export default ModelsPage;
