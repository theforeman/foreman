import React from 'react';
import PropTypes from 'prop-types';
import { Router } from 'react-router-dom';
import history from '../history';

import Layout, { propTypes as LayoutPropTypes } from '../components/Layout';
import AppSwitcher from '../routes';

const ReactApp = ({ data: { layout } }) => (
  <Router history={history}>
    <Layout data={layout}>
      <AppSwitcher />
    </Layout>
  </Router>
);

ReactApp.propTypes = {
  data: PropTypes.shape({
    layout: LayoutPropTypes.data,
    metadata: PropTypes.object,
  }).isRequired,
};

export default ReactApp;
