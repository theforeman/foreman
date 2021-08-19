import PropTypes from 'prop-types';
import React from 'react';
import { useSelector, shallowEqual } from 'react-redux';
import { Switch, Route } from 'react-router-dom';

import { fallbackRoute, renderRoute } from '../RoutingService';
import { selectRoutes } from '../RouterSelector';

const ForemanSwitcher = ({ children: coreRoutes }) => {
  const routes = useSelector(() => selectRoutes(coreRoutes), shallowEqual);

  return (
    <Switch>
      {routes}
      <Route
        render={child => renderRoute(null, child, fallbackRoute)}
        key="default-route"
      />
    </Switch>
  );
};

ForemanSwitcher.propTypes = {
  children: PropTypes.arrayOf(PropTypes.node).isRequired,
};

export default ForemanSwitcher;
