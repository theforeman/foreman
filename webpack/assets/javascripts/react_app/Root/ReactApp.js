import React from 'react';
import PropTypes from 'prop-types';
import { ConnectedRouter } from 'connected-react-router';
import { ApolloProvider } from '@apollo/client';
import history from '../history';
import { getForemanContext } from '../Root/Context/ForemanContext';
import Layout, { propTypes as LayoutPropTypes } from '../components/Layout';
import AppSwitcher from '../routes';

import apolloClient from './apollo';
import ToastsList from '../components/ToastsList';
import ConfirmModal from '../components/ConfirmModal';

const ReactApp = ({ layout, metadata, toasts, routes }) => {
  const contextData = { metadata };
  const ForemanContext = getForemanContext(contextData);

  return (
    <div id="react-app-root">
      <ForemanContext.Provider value={contextData}>
        <ApolloProvider client={apolloClient}>
          <ConnectedRouter history={history}>
            <Layout data={layout}>
              <ToastsList railsMessages={toasts} />
              <AppSwitcher serverRoutes={routes} />
              <ConfirmModal />
            </Layout>
          </ConnectedRouter>
        </ApolloProvider>
      </ForemanContext.Provider>
    </div>
  );
};

ReactApp.propTypes = {
  layout: LayoutPropTypes.data.isRequired,
  metadata: PropTypes.object.isRequired,
  toasts: PropTypes.array.isRequired,
  routes: PropTypes.array.isRequired,
};

export default ReactApp;
