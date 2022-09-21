import React from 'react';

import NewFiltersFormPage from './NewFiltersFormPage';
import EditFiltersFormPage from './EditFiltersFormPage';
import { FILTERS_PATH_NEW, FILTERS_PATH_EDIT } from './constants';

export default [
  {
    path: FILTERS_PATH_NEW,
    render: props => <NewFiltersFormPage data={{}} {...props} />,
    exact: true,
  },
  {
    path: FILTERS_PATH_EDIT,
    render: props => <EditFiltersFormPage {...props} />,
    exact: true,
  },
];
