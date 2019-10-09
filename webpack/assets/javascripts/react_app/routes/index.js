import React from 'react';
import PropTypes from 'prop-types';
import { Switch, Route } from 'react-router-dom';
import { routes } from './routes';

let currentLocation = null;

const AppSwitcher = props => (
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
            (child.location.state &&
              child.location.state.useTurbolinks &&
              !window.history.state.turbolinks) ||
            !child.location.state;

          if (useTurbolinks) window.Turbolinks.visit(child.location.pathname);
        }
        currentLocation = child.location;
        return props.children ? props.children : null;
      }}
    />
  </Switch>
);

AppSwitcher.propTypes = {
  children: PropTypes.object,
};

AppSwitcher.defaultProps = {
  children: null,
};

export default AppSwitcher;
