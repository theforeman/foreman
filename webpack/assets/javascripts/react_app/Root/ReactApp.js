import React from 'react';
import PropTypes from 'prop-types';
import { ConnectedRouter } from 'connected-react-router';
import history from '../history';
import { getForemanContext } from '../Root/Context/ForemanContext';
import Layout, { propTypes as LayoutPropTypes } from '../components/Layout';
import AppSwitcher from '../routes';

const ReactApp = ({ data: { layout, metadata, toasts } }) => {
  const contextData = { metadata, toasts };
  const ForemanContext = getForemanContext(contextData);

  return (
    <ForemanContext.Provider value={contextData}>
      <ConnectedRouter history={history}>
        <Layout data={layout}>
          <AppSwitcher />
        </Layout>
      </ConnectedRouter>
    </ForemanContext.Provider>
  );
};

ReactApp.propTypes = {
  data: PropTypes.shape({
    layout: LayoutPropTypes.data.isRequired,
    metadata: PropTypes.object.isRequired,
    toasts: PropTypes.array.isRequired,
  }).isRequired,
};

export default ReactApp;
