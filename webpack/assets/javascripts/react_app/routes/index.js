import React from 'react';
import { Switch, Route } from 'react-router-dom';
import { routes } from './routes';

let currentLocation = null;

const AppSwitcher = () => (
  <Switch>
    {routes.map(({ render, path, ...routeProps }) => (
      <Route
        path={path}
        key={path}
        {...routeProps}
        render={renderProps => {
          const railsContainer = document.getElementById('rails-app-content');
          if (railsContainer) railsContainer.remove();
          currentLocation = renderProps.location;

          return render(renderProps);
        }}
      />
    ))}
    <Route
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

export default AppSwitcher;
