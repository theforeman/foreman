import React from 'react';
import PropTypes from 'prop-types';
import { Router } from 'react-router-dom';
import history from '../history';

import BrowserSupport from '../components/BrowserSupport';
import Layout from '../components/Layout';
import AppSwitcher from '../routes';

const ReactApp = ({ data: { layout } }) => (
  <React.Fragment>
    <BrowserSupport />
    <Router history={history}>
      <Layout data={layout}>
        <AppSwitcher />
      </Layout>
    </Router>
  </React.Fragment>
);

ReactApp.propTypes = {
  data: PropTypes.shape({
    layout: Layout.propTypes.data,
    metadata: PropTypes.object,
  }).isRequired,
};

export default ReactApp;
