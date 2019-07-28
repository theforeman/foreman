import React from 'react';
import { Route } from 'react-router-dom';
import PropTypes from 'prop-types';
import { routes } from './routes';
import { renderRoute } from './RoutingService';
import ForemanSwitch from './ForemanSwitcher';

const AppSwitcher = () => (
  <ForemanSwitch>
    {routes.map(({ render, path, ...routeProps }) => (
      <Route
        path={path}
        key={path}
        {...routeProps}
        render={renderProps => renderRoute(render, renderProps)}
      />
    ))}
  </ForemanSwitch>
);

AppSwitcher.propTypes = {
  children: PropTypes.object,
};

AppSwitcher.defaultProps = {
  children: null,
};

export default AppSwitcher;
