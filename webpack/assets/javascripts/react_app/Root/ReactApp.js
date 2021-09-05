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
import ErrorBoundary from '../components/common/ErrorBoundary';
import ConfirmModal from '../components/ConfirmModal';

const ReactApp = ({ layout, metadata, toasts }) => {
  const contextData = { metadata };
  const ForemanContext = getForemanContext(contextData);

  return (
    <div id="react-app-root">
      <ForemanContext.Provider value={contextData}>
        <ApolloProvider client={apolloClient}>
          <ConnectedRouter history={history}>
            <Layout data={layout}>
              <ErrorBoundary history={history}>
                <ToastsList railsMessages={toasts} />
                <AppSwitcher />
                <ConfirmModal />
              </ErrorBoundary>
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
};

export default ReactApp;
