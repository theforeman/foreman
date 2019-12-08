import React from 'react';
import PropTypes from 'prop-types';
import { ConnectedRouter } from 'connected-react-router';
import history from '../history';

import Layout, { propTypes as LayoutPropTypes } from '../components/Layout';
import AppSwitcher from '../routes/AppSwitcher';

const ReactApp = ({ data: { layout } }) => (
  <ConnectedRouter history={history}>
    <Layout data={layout}>
      <AppSwitcher />
    </Layout>
  </ConnectedRouter>
);

ReactApp.propTypes = {
  data: PropTypes.shape({
    layout: LayoutPropTypes.data,
    metadata: PropTypes.object,
  }).isRequired,
};

export default ReactApp;
