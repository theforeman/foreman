import PropTypes from 'prop-types';
import React from 'react';
import { useSelector, shallowEqual } from 'react-redux';
import { Switch, Route } from 'react-router-dom';

import { fallbackRoute } from '../RoutingService';
import { selectRoutes } from '../RouterSelector';
import { OVERRIDE_ROUTES } from './OverrideRoutes';

const ForemanSwitcher = ({ children: coreRoutes }) => {
  const routes = useSelector(() => selectRoutes(coreRoutes), shallowEqual);

  return (
    <Switch>
      {OVERRIDE_ROUTES.map(({ path, exact }) => (
        <Route path={path} exact={exact} render={fallbackRoute} key={path} />
      ))}
      {routes}
      <Route render={fallbackRoute} key="default-route" />
    </Switch>
  );
};

ForemanSwitcher.propTypes = {
  children: PropTypes.arrayOf(PropTypes.node).isRequired,
};

export default ForemanSwitcher;
