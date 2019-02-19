import React from 'react';
import PropTypes from 'prop-types';
import { Router } from 'react-router-dom';
import history from './history';

import Layout from './components/Layout';
import routes from './routes';

const App = ({ data: { layout } }) => (
  <Router history={history}>
    <Layout data={layout}>{routes}</Layout>
  </Router>
);

App.propTypes = {
  data: PropTypes.shape({ layout: Layout.propTypes.data }).isRequired,
};

export default App;
