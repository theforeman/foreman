import React from 'react';
import { Switch, Route } from 'react-router-dom';
import { routes } from './routes';
import { visit } from '../../foreman_navigation';

let currentPath = window.location.href;

const AppSwitcher = () => {
  const updateCurrentPath = nextPath => {
    currentPath = nextPath;
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
    const nextPath = window.location.href;
    if (currentPath !== nextPath) {
      updateCurrentPath(nextPath);
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
          render={componentProps => handleRoute(Component, componentProps)}
        />
      ))}
      <Route render={handleFallbackRoute} />
    </Switch>
  );
};

export default AppSwitcher;
