import React from 'react';
import { Route } from 'react-router-dom';
import PropTypes from 'prop-types';
import Layout from '../components/Layout';
import { layoutPropTypes } from '../components/Layout/Layout';

const RouteWithLayout = ({ render, layout, ...rest }) => (
  <Route
    {...rest}
    render={matchProps => <Layout data={layout}>{render(matchProps)}</Layout>}
  />
);

delete layoutPropTypes.history;

RouteWithLayout.propTypes = {
  render: PropTypes.func.isRequired,
  layout: PropTypes.shape(layoutPropTypes).isRequired,
};

export default RouteWithLayout;
