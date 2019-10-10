import React from 'react';

import ModelsPage from './ModelsPage';
import { MODELS_PATH } from './constants';

export default {
  path: MODELS_PATH,
  render: props => <ModelsPage {...props} />,
  exact: true,
};
