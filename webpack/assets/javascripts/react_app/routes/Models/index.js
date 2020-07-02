import React from 'react';

import ModelsPage from './ModelsPage';
import NewModelPage from './NewModelPage';
import { MODELS_PATH, NEW_MODEL_PATH } from './constants';

export default [
  {
    path: MODELS_PATH,
    render: props => <ModelsPage {...props} />,
    exact: true,
  },
  {
    path: NEW_MODEL_PATH,
    render: props => <NewModelPage {...props} />,
    exact: true,
  },
];
