import React from 'react';

import { Router } from 'react-router-dom';
import history from '../history';
import AppSwitcher from '../routes';

const withReactRoutes = Component => props => (
  <Router history={history}>
    <AppSwitcher>
      <Component {...props} />
    </AppSwitcher>
  </Router>
);

export default withReactRoutes;
