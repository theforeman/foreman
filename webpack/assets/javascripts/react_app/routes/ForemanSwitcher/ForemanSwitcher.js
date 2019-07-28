import React from 'react';
import { Switch, Route } from 'react-router-dom';
import PropTypes from 'prop-types';
import { fallbackRoute, renderRoute } from '../RoutingService';

const ForemanSwitcher = ({ routes }) => (
  <Switch>
    {routes}
    <Route
      render={child => renderRoute(null, child, fallbackRoute)}
      key="default-route"
    />
  </Switch>
);

ForemanSwitcher.propTypes = {
  routes: PropTypes.arrayOf(PropTypes.node).isRequired,
};

export default ForemanSwitcher;
