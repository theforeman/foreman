import React from 'react';
import { Switch, Route } from 'react-router-dom';
import { routes } from './routes';
import { visit } from '../../foreman_navigation';

let currentPath = window.location.pathname;

const AppSwitcher = () => {
  const updateCurrentPath = () => {
    currentPath = window.location.pathname;
  };

  const handleRailsContainer = () => {
    const railsContainer = document.getElementById('rails-app-content');
    if (railsContainer) railsContainer.remove();
  };

  const handleRoute = (Component, props) => {
    handleRailsContainer();
    updateCurrentPath();
    return <Component {...props} />;
  };

  const handleFallbackRoute = () => {
    const nextPath = window.location.pathname;
    if (currentPath !== nextPath) {
      updateCurrentPath();
      visit(nextPath);
    }
    return null;
  };

  return (
    <Switch>
      {routes.map(({ render: Component, path, ...routeProps }) => (
        <Route
          path={path}
          key={path}
          {...routeProps}
          render={props => handleRoute(Component, props)}
        />
      ))}
      <Route render={handleFallbackRoute} />
    </Switch>
  );
};

export default AppSwitcher;
