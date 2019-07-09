import React from 'react';
import { Switch } from 'react-router-dom';
import PropTypes from 'prop-types';

import { routes } from './routes';
import LayoutRoute from './RouteWithLayout';
import { layoutPropTypes } from '../components/Layout/Layout';
import ForemanRoute from './ForemanRoute';

let currentLocation = null;

const removeRootContainer = renderProps => {
  const railsContainer = document.getElementById('rails-app-content');

  if (railsContainer) {
    railsContainer.remove();
  }
  currentLocation = renderProps.location;
};

const AppSwitcher = ({ data: { layout } }) => (
  <Switch>
    {routes.map(({ render, path, skipLayout, ...routeProps }) => (
      <ForemanRoute
        key={path}
        render={render}
        layout={layout}
        path={path}
        skipLayout={skipLayout}
        beforeRender={removeRootContainer}
        {...routeProps}
      />
    ))}
    <LayoutRoute
      layout={layout}
      render={child => {
        if (
          currentLocation &&
          currentLocation.pathname !== child.location.pathname
        ) {
          const useTurbolinks =
            child.location.state &&
            child.location.state.useTurbolinks &&
            !window.history.state.turbolinks; // visit() already called

          if (useTurbolinks) window.Turbolinks.visit(child.location.pathname);
        }
        currentLocation = child.location;
        return null;
      }}
    />
  </Switch>
);

AppSwitcher.propTypes = {
  data: PropTypes.shape({
    layout: PropTypes.shape(layoutPropTypes),
  }).isRequired,
};

export default AppSwitcher;
