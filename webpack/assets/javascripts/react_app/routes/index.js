import React from 'react';
import PropTypes from 'prop-types';
import { Switch, Route } from 'react-router-dom';

import { routes } from './routes';

let currentLocation = null;

const AppSwitcher = () => (
  <Switch>
    {routes.map(({ render, ...props }) => (
      <Route
        {...props}
        key={props.path}
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

AppSwitcher.propTypes = {
  path: PropTypes.string,
};

AppSwitcher.defaultProps = {
  path: '',
};

export default AppSwitcher;
